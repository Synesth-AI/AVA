import Foundation

class MuseEEGReceiver {
    private var t: Float = 0.0

    func getBandPowers() -> EEGReading {
        t += 0.1
        let alpha = 0.5 + 0.1 * sin(t)
        let beta = 0.2 + 0.05 * cos(t)
        let gamma = 0.1 + 0.02 * sin(2 * t)
        let theta = 0.15 + 0.03 * cos(t)
        // For compatibility with your DataModels, delta is not used directly
        let alphaThetaPresence = (Double(alpha) + Double(theta)) / 2.0
        let betaGammaChaos = (Double(beta) + Double(gamma)) / 2.0
        return EEGReading(
            alpha: Double(alpha),
            beta: Double(beta),
            gamma: Double(gamma),
            theta: Double(theta),
            delta: 0.05 + 0.01 * Double(sin(Double(t))),
            // Computed properties are handled in the struct, but you can pass these for convenience
            // alphaThetaPresence: alphaThetaPresence,
            // betaGammaChaos: betaGammaChaos
        )
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
