import Foundation

class KXRPEquationBank {
    let epsilon = 0.01

    func computeKXRP(index: Int, eeg: EEGReading, hrv: HRVMetrics, voice: VoiceFeatures, entropy: Double, psi: Double, psiPrev: Double) -> Double {
        switch index {
        case 1:
            return computePresenceIndex(eeg: eeg, entropy: entropy)
        case 12:
            return computeSuppressionCoefficient(voice: voice, hrv: hrv, entropy: entropy, eeg: eeg)
        case 27:
            return computeMemoryRecall(eeg: eeg, voice: voice, hrv: hrv)
        case 41:
            return computeDriftDelta(psi: psi, psiPrev: psiPrev)
        // ...cases for 2–50...
        default:
            return 0.0
        }
    }

    private func computePresenceIndex(eeg: EEGReading, entropy: Double) -> Double {
        return (eeg.alpha + eeg.theta) / (entropy + epsilon)
    }

    private func computeSuppressionCoefficient(voice: VoiceFeatures, hrv: HRVMetrics, entropy: Double, eeg: EEGReading) -> Double {
        return (voice.calmMatch + hrv.coherence) / (entropy + eeg.beta + epsilon)
    }

    private func computeMemoryRecall(eeg: EEGReading, voice: VoiceFeatures, hrv: HRVMetrics) -> Double {
        return (eeg.theta + voice.pauseDisorder) / (eeg.beta + hrv.entropy + epsilon)
    }

    private func computeDriftDelta(psi: Double, psiPrev: Double) -> Double {
        return abs(psi - psiPrev)
    }

    // ...implementations for other equations...
}
