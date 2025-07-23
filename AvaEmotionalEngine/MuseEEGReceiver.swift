import Foundation

class MuseEEGReceiver {
    private var t: Float = 0.0

    func getBandPowers() -> EEGReading {
        t += 0.1
        // Add randomness to each band to trigger more state changes
        let tDouble = Double(t)
        let alpha = 0.5 + 0.1 * sin(tDouble) + Double.random(in: -0.15...0.15)
        let beta = 0.2 + 0.05 * cos(tDouble) + Double.random(in: -0.10...0.10)
        let gamma = 0.1 + 0.02 * sin(2 * tDouble) + Double.random(in: -0.05...0.05)
        let theta = 0.15 + 0.03 * cos(tDouble) + Double.random(in: -0.10...0.10)
        let delta = 0.05 + 0.01 * sin(tDouble) + Double.random(in: -0.02...0.02)
        return EEGReading(
            alpha: alpha,
            beta: beta,
            gamma: gamma,
            theta: theta,
            delta: delta
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
