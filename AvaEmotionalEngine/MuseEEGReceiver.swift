import Foundation
import MuseSDK

/// Wrapper for Muse 2 headband using MuseSDK
class MuseEEGReceiver: NSObject, IXNMuseDelegate, IXNMuseConnectionListener {
    private var latestAlpha: Double = 0.0
    private var latestBeta: Double = 0.0
    private var latestGamma: Double = 0.0
    private var latestTheta: Double = 0.0
    private var latestDelta: Double = 0.0
    private var muse: IXNMuse?

    override init() {
        super.init()
        // Initialize and configure Muse SDK
        IXNMuse.initMuseSDK()
        IXNMuse.startListening(forConnections: self)
    }

    /// Returns the most recent band powers received from the Muse device
    func getBandPowers() -> EEGReading {
        return EEGReading(
            alpha: latestAlpha,
            beta: latestBeta,
            gamma: latestGamma,
            theta: latestTheta,
            delta: latestDelta
        )
    }

    // MARK: - IXNMuseConnectionListener
    func muse(_ muse: IXNMuse, connectionDidChange state: IXNMuseConnectionState) {
        if state == .connected {
            self.muse = muse
            muse.register(self)
            // Subscribe to band power data
            muse.enableBandpower(on: .alpha)
            muse.enableBandpower(on: .beta)
            muse.enableBandpower(on: .gamma)
            muse.enableBandpower(on: .theta)
            muse.enableBandpower(on: .delta)
            muse.start()
        }
    }

    // MARK: - IXNMuseDelegate
    func muse(_ muse: IXNMuse, didReceivePacket packet: IXNMuseDataPacket) {
        guard packet.packetType == .bandpower else { return }
        // packet.values: [delta, theta, alpha, beta, gamma]
        let values = packet.values
        if values.count >= 5 {
            latestDelta = values[0]
            latestTheta = values[1]
            latestAlpha = values[2]
            latestBeta = values[3]
            latestGamma = values[4]
        }
    }
}

class HRVEmulator {
    private var t: Float = 0.0

    func getMetrics() -> HRVMetrics {
        t += 0.1
        let rmssd = 0.3 + 0.3 * abs(sin(t))
        let sdnn = 0.2 + 0.3 * abs(cos(t))
        let lf = 0.5 + 0.2 * sin(2 * t)
        let hf = 0.5 + 0.2 * cos(2 * t)
        return HRVMetrics(
            sdnn: Double(sdnn),
            rmssd: Double(rmssd),
            lf: Double(lf),
            hf: Double(hf)
        )
    }
}

class VoiceFeatureExtractor {
    private var t: Float = 0.0

    func getFeatures() -> VoiceFeatures {
        t += 0.1
        let jitter = 0.01 + 0.01 * abs(sin(t))
        let shimmer = 0.02 + 0.01 * abs(cos(t))
        let hnr = 0.7 + 0.2 * sin(t)
        let pauseCount = Int(3 + 2 * sin(t))
        let speakingRate = Double(120.0 + 30.0 * cos(t))
        let facialConsistencyScore = 0.7 + 0.2 * abs(sin(t))
        return VoiceFeatures(
            jitter: Double(jitter),
            shimmer: Double(shimmer),
            hnr: Double(hnr),
            pauseCount: pauseCount,
            speakingRate: speakingRate,
            facialConsistencyScore: Double(facialConsistencyScore)
        )
    }
}
