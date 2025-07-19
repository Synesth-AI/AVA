import Foundation

/// Output of the neural-symbolic bridge
public struct KXRPResult {
    public let ksxDelta: Double
    public let psiOmegaLock: Bool
    public let symbolicClassifications: [String]
    public let forecastScore: Double
    public let mesqi: Double
}

public class KXRPInterpreter {
    private let engine = KXRPEngine()
    /// Interpret a raw EEG snapshot into a symbolic result
    public func interpret(eegBands: EEGReading, hrv: HRVMetrics, voice: VoiceFeatures) -> KXRPResult {
        let ksx = computeKSX(eegBands)
        let lock = ksx < 0.2
        let symbols = classifySymbolicTruths(from: eegBands)
        let forecast = predictSymbolicDrift(ksx: ksx)
        let mesqi = computeMESQI(eeg: eegBands, hrv: hrv, voice: voice)
        return KXRPResult(
            ksxDelta: ksx,
            psiOmegaLock: lock,
            symbolicClassifications: symbols,
            forecastScore: forecast,
            mesqi: mesqi
        )
    }

    private func computeKSX(_ e: EEGReading) -> Double {
        // ΔKSX = |α – β| + |γ – θ|
        return abs(e.alpha - e.beta) + abs(e.gamma - e.theta)
    }

    private func classifySymbolicTruths(from e: EEGReading) -> [String] {
        var results = [String]()
        if e.theta > 0.7 && e.alpha < 0.3 {
            results.append("Suppressed Emotion")
        }
        if e.gamma > 0.6 && e.theta < 0.3 {
            results.append("Covert Internal Speech")
        }
        if e.alpha > 0.6 && e.beta < 0.3 {
            results.append("Emotional Memory Echo")
        }
        if e.delta > 0.5 && e.gamma < 0.3 {
            results.append("Symbolic Dissonance")
        }
        return results
    }

    private func predictSymbolicDrift(ksx: Double) -> Double {
        // Higher KSX implies higher drift risk
        return min(1.0, ksx / 1.5)
    }

    /// Compute MESQI as weighted combination of truth, inverted entropy, coherence, and visual sync
    private func computeMESQI(eeg: EEGReading, hrv: HRVMetrics, voice: VoiceFeatures) -> Double {
        let entropyScore = engine.computeEntropy(eeg: eeg, hrv: hrv, voice: voice)
        let omegaScore = engine.computeTruthSignal(eeg: eeg, voice: voice)
        let coherenceScore = engine.computeCoherence(eeg: eeg, hrv: hrv)
        let visualSync = voice.facialConsistencyScore
        let weighted = (0.35 * omegaScore) +
                       (0.25 * (1.0 - entropyScore)) +
                       (0.25 * coherenceScore) +
                       (0.15 * visualSync)
        return min(max(weighted, 0.0), 1.0)
    }
}
