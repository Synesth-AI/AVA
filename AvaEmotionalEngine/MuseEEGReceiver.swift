import Foundation
import Accelerate

/// Streams live EEG data from a connected Muse headset and computes band powers (α, β, γ, θ, δ)
/// The class registers itself as an `IXNMuseDataListener` and updates `latestReading` whenever a
/// new EEG packet arrives. Consumers can either observe the `latestReading` publisher or call
/// `getBandPowers()` synchronously.
final class MuseEEGReceiver: NSObject, ObservableObject {
    static let shared = MuseEEGReceiver()
    private override init() { super.init() }
    // MARK: - Public Publishers
    /// The most recent band-power reading calculated from incoming EEG packets
    @Published private(set) var latestReading: EEGReading = .init(alpha: 0, beta: 0, gamma: 0, theta: 0, delta: 0)
    
    /// The most recent FFT spectrum
    @Published private(set) var latestSpectrum: [Double] = []

    // MARK: - Private Properties
    private weak var muse: IXNMuse?
    @Published private(set) var isStreaming: Bool = false
    private let sampleRate: Int = 256          // Muse 2 & S: 256 Hz
    private let windowSize: Int = 256          // 1 second window
    private var lastLogTime: Date = .distantPast
    private var circularBuffer: [Double] = []  // Sliding window of raw EEG µV values (FP1 electrode)

    // MARK: - Lifecycle
    /// Call this after a Muse is connected to begin streaming.
    func startStreaming(from muse: IXNMuse) {
        stopStreaming() // in case we're already registered
        self.muse = muse
        circularBuffer.removeAll(keepingCapacity: true)
        muse.register(self, type: .eeg)
        isStreaming = true
    }

    /// Stop receiving EEG packets and clear state.
    func stopStreaming() {
        muse?.unregisterDataListener(self, type: .eeg)
        muse = nil
        circularBuffer.removeAll()
        latestReading = .init(alpha: 0, beta: 0, gamma: 0, theta: 0, delta: 0)
        isStreaming = false
    }

    /// Synchronous accessor (optional).
    func getBandPowers() -> EEGReading { latestReading }
}

// MARK: - IXNMuseDataListener
extension MuseEEGReceiver: IXNMuseDataListener {
    // Handle data packets (EEG)
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        guard let packet = packet, packet.packetType() == .eeg else { return }
        // `packet.values()` returns NSNumber array for 4 EEG channels; use channel 0 (TP9) here
        guard let first = packet.values().first else { return }
        let µV = first.doubleValue

        // Maintain circular buffer of `windowSize` samples
        if circularBuffer.count >= windowSize { circularBuffer.removeFirst() }
        circularBuffer.append(µV)

        // Only compute band powers when the buffer is full
        guard circularBuffer.count == windowSize else { return }
        latestReading = computeBandPowers(from: circularBuffer)
        // Throttled console log (once per second)
        let now = Date()
        if now.timeIntervalSince(lastLogTime) >= 1 {
            print(String(format: "EEG α: %.2f β: %.2f γ: %.2f θ: %.2f δ: %.2f", latestReading.alpha, latestReading.beta, latestReading.gamma, latestReading.theta, latestReading.delta))
            lastLogTime = now
        }
    }

    // Required by protocol but ignored for now.
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        // Currently not processing artifact packets
    }
}

// MARK: - DSP helpers
private extension MuseEEGReceiver {
    /// Hann-window the signal, perform FFT, and integrate power in each canonical EEG band.
    func computeBandPowers(from signal: [Double]) -> EEGReading {
        // 1. Apply Hann window
        var windowed = [Double](repeating: 0, count: signal.count)
        vDSP_hann_windowD(&windowed, vDSP_Length(signal.count), Int32(vDSP_HANN_NORM))
        vDSP_vmulD(signal, 1, windowed, 1, &windowed, 1, vDSP_Length(signal.count))

        // 2. Convert to Float and prepare FFT
        let floatSignal = windowed.map(Float.init)
        let log2n = vDSP_Length(log2(Float(signal.count)))
        guard let fftSetup = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self) else {
            return latestReading
        }
        let n = signal.count
        var real = floatSignal + [Float](repeating: 0, count: n) // pad length if needed
        var imag = [Float](repeating: 0, count: n)
        // 3. Compute magnitude spectrum after FFT
        var magnitudes = [Float](repeating: 0, count: n/2)
        real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var split = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                fftSetup.forward(input: split, output: &split)
                vDSP.absolute(split, result: &magnitudes)
            }
        }

        // 4. Integrate power in each band
        func power(from fMin: Double, to fMax: Double) -> Double {
            let res = Double(sampleRate) / Double(n)
            let start = Int(fMin / res)
            let end   = min(Int(fMax / res), magnitudes.count - 1)
            guard start < end else { return 0 }
            let slice = magnitudes[start...end]
            let sum = slice.reduce(0, +)
            return Double(sum) / Double(slice.count)
        }
        // Convert magnitudes to Double and store the spectrum up to 50Hz
        let maxFreqIndex = min(Int(50.0 / (Double(sampleRate) / Double(n))), magnitudes.count - 1)
        let spectrum = (0...maxFreqIndex).map { Double(magnitudes[$0]) }
        
        return EEGReading(
            alpha: power(from: 8,  to: 13),
            beta:  power(from: 13, to: 30),
            gamma: power(from: 30, to: 50),
            theta: power(from: 4,  to: 8),
            delta: power(from: 0.5, to: 4),
            spectrum: spectrum
        )
    }
}
class HRVEmulator {
    private var t: Float = 0.0

    func getMetrics() -> HRVMetrics {
        t += 0.1
        // Add randomness to HRV metrics
        let tDouble = Double(t)
        let rmssd = 0.3 + 0.3 * abs(sin(tDouble)) + Double.random(in: -0.15...0.15)
        let sdnn = 0.2 + 0.3 * abs(cos(tDouble)) + Double.random(in: -0.10...0.10)
        let lf = 0.5 + 0.2 * sin(2 * tDouble) + Double.random(in: -0.10...0.10)
        let hf = 0.5 + 0.2 * cos(2 * tDouble) + Double.random(in: -0.10...0.10)
        return HRVMetrics(
            sdnn: sdnn,
            rmssd: rmssd,
            lf: lf,
            hf: hf
        )
    }
}

class VoiceFeatureExtractor {
    private var t: Float = 0.0

    func getFeatures() -> VoiceFeatures {
        t += 0.1
        let tDouble = Double(t)
        let jitter = 0.01 + 0.01 * abs(sin(tDouble))
        let shimmer = 0.02 + 0.01 * abs(cos(tDouble))
        let hnr = 0.7 + 0.2 * sin(tDouble)
        let pauseCount = Int(3 + 2 * sin(tDouble))
        let speakingRate = 120.0 + 30.0 * cos(tDouble)
        let facialConsistencyScore = 0.7 + 0.2 * abs(sin(tDouble))
        return VoiceFeatures(
            jitter: jitter,
            shimmer: shimmer,
            hnr: hnr,
            pauseCount: pauseCount,
            speakingRate: speakingRate,
            facialConsistencyScore: facialConsistencyScore
        )
    }
}
