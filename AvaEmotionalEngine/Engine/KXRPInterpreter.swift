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
    /// Interpret a raw EEG snapshot into a symbolic result
    public func interpret(eegBands: EEGReading) -> KXRPResult {
        let ksx = computeKSX(eegBands)
        let lock = ksx < 0.2
        let symbols = classifySymbolicTruths(from: eegBands)
        let forecast = predictSymbolicDrift(ksx: ksx)
        let mesqi = computeMESQI(eegBands, ksx: ksx)
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

    private func computeMESQI(_ eeg: EEGReading, ksx: Double) -> Double {
        // MESQI = avg(stability, harmony)
        let stability = 1.0 - ksx
        let harmony = (eeg.alpha + eeg.gamma) / 2.0
        return (stability + harmony) / 2.0
    }
}
