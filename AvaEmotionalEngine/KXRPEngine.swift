import Foundation

class KXRPEngine {
    private let equationBank = KXRPEquationBank()
    private var psiPrev: Double = 0.0

    // Main entry: computes all KXRP metrics and returns the selected one (default: 1)
    func computeMetrics(
        eeg: EEGReading,
        hrv: HRVMetrics,
        voice: VoiceFeatures,
        index: Int = 1
    ) -> (psi: Float, entropy: Float, coherence: Float, integrity: Float) {
        // Compute core metrics
        let psi = computePsi(eeg: eeg, hrv: hrv, voice: voice)
        let entropy = computeEntropy(eeg: eeg, hrv: hrv, voice: voice)
        let coherence = computeCoherence(eeg: eeg, hrv: hrv)
        let integrity = computeTruthSignal(eeg: eeg, voice: voice)

        // Compute advanced KXRP metric
        let kxrp = equationBank.computeKXRP(
            index: index,
            eeg: eeg,
            hrv: hrv,
            voice: voice,
            entropy: entropy,
            psi: psi,
            psiPrev: psiPrev
        )

        // Update previous psi for next call
        psiPrev = psi

        // Return as tuple (for now, use kxrp as psi for demonstration)
        return (Float(kxrp), Float(entropy), Float(coherence), Float(integrity))
    }

    // Core metric computations (same as in your test code)
    private func computePsi(eeg: EEGReading, hrv: HRVMetrics, voice: VoiceFeatures) -> Double {
        let eegScore = (eeg.alpha + eeg.theta) / 2.0
        let hrvScore = hrv.coherence
        let voiceScore = voice.hnr
        return (0.4 * eegScore) + (0.4 * hrvScore) + (0.2 * voiceScore)
    }

    private func computeEntropy(eeg: EEGReading, hrv: HRVMetrics, voice: VoiceFeatures) -> Double {
        let brainNoise = eeg.betaGammaChaos
        let heartFluct = hrv.entropy
        let speechJitter = voice.pauseDisorder
        return (brainNoise + heartFluct + speechJitter) / 3.0
    }

    private func computeCoherence(eeg: EEGReading, hrv: HRVMetrics) -> Double {
        let alpha = eeg.alpha
        let hrvCoh = hrv.coherence
        return (alpha + hrvCoh) / 2.0
    }

    private func computeTruthSignal(eeg: EEGReading, voice: VoiceFeatures) -> Double {
        let symbolicAlignment = 0.5
        let facialEntropyDrop = voice.facialConsistencyScore
        return (0.6 * symbolicAlignment) + (0.4 * facialEntropyDrop)
    }
}