import Foundation
import Muse

class MuseEEGReceiver: NSObject {
    // MARK: - Properties
    private var muse: IXNMuse?
    private var lastEEGReading = EEGReading(alpha: 0, beta: 0, gamma: 0, theta: 0, delta: 0)
    private var isConnected = false
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupMuse()
    }
    
    // MARK: - Public Methods
    func getBandPowers() -> EEGReading {
        return lastEEGReading
    }
    
    func connect() {
        guard let muse = muse else { 
            print("No Muse found. Make sure your headset is on and in range.")
            return 
        }
        muse.runAsynchronously()
    }
    
    // MARK: - Private Methods
    private func setupMuse() {
        // Get the first available Muse
        if let availableMuses = IXNMuseManagerIos.sharedInstance()?.getMuses() as? [IXNMuse], 
           !availableMuses.isEmpty {
            self.muse = availableMuses[0]
            self.muse?.delegate = self
            self.muse?.register(self)
            print("Muse found: \(availableMuses[0].name ?? "Unknown")")
        } else {
            print("No Muses found. Make sure your headset is on and in range.")
        }
    }
    
    // MARK: - Data Processing
    private func updateBandPowers(from packet: IXNMuseDataPacket) {
        // Simple processing - replace with proper FFT in production
        let values = packet.values
        lastEEGReading = EEGReading(
            alpha: Double(values[0]) * 0.4,
            beta: Double(values[1]) * 0.3,
            gamma: Double(values[2]) * 0.2,
            theta: Double(values[3]) * 0.5,
            delta: 0.1  // Delta requires more processing
        )
    }
}

// MARK: - IXNMuseDelegate
extension MuseEEGReceiver: IXNMuseDelegate {
    func museListChanged() {
        print("Muse list changed - attempting to reconnect...")
        setupMuse()
    }
    
    func museConnectionPacketReceived(_ packet: IXNConnectionPacket, muse: IXNMuse?) {
        if packet.currentConnectionState == .connected {
            isConnected = true
            print("Muse connected: \(muse?.name ?? "Unknown")")
            // Subscribe to EEG data
            muse?.register(self, type: .eeg)
            muse?.register(self, type: .battery)
        } else if packet.currentConnectionState == .disconnected {
            print("Muse disconnected")
            isConnected = false
        }
    }
}

// MARK: - IXNMuseDataListener
extension MuseEEGReceiver: IXNMuseDataListener {
    func receive(_ packet: IXNMuseDataPacket, type: IXNMuseDataPacketType) {
        switch type {
        case .eeg:
            updateBandPowers(from: packet)
        case .battery:
            if let batteryLevel = packet.values.first {
                print("Battery level: \(batteryLevel * 100)%")
            }
        default:
            break
        }
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, _: IXNMuseDataListenerType?) {
        // Handle artifact packets if needed
    }
}

// MARK: - Keep existing emulator classes
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
