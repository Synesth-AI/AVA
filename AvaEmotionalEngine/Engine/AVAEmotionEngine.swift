// EEG, HRV, and Voice input data models
struct EEGReading {
    let alpha: Double
    let theta: Double
    let beta: Double
    let gamma: Double
    let alphaThetaPresence: Double
    let betaGammaChaos: Double
}

struct HRVMetrics {
    let rmssd: Double
    let sdnn: Double
    let coherence: Double
    let entropy: Double
}

struct VoiceFeatures {
    let calmMatch: Double       // 0–1, grounded speech
    let pauseDisorder: Double   // 0–1, high = stress/tension
    let facialConsistencyScore: Double  // 0–1, truth-to-expression alignment
}

// AVAEmotionEngine.swift

import Foundation

class AVAEmotionalEngine {
    // Core emotional state
    var psiCurrent: Double = 0.0
    var psiPrevious: Double = 0.0
    var coherence: Double = 0.0
    var entropy: Double = 0.0
    var omega: Double = 0.0

    // Update engine with new input
    func updateFromInputStreams(eeg: EEGReading?, hrv: HRVMetrics?, voice: VoiceFeatures?) {
        psiPrevious = psiCurrent
        psiCurrent = computePsi(eeg: eeg, hrv: hrv, voice: voice)
        entropy = computeEntropy(eeg: eeg, hrv: hrv, voice: voice)
        coherence = computeCoherence(eeg: eeg, hrv: hrv)
        omega = computeTruthSignal(eeg: eeg, voice: voice)
        detectDrift()
    }

    private func computePsi(eeg: EEGReading?, hrv: HRVMetrics?, voice: VoiceFeatures?) -> Double {
        let eegScore = eeg?.alphaThetaPresence ?? 0.0
        let hrvScore = hrv?.coherence ?? 0.0
        let voiceScore = voice?.calmMatch ?? 0.0
        return (0.4 * eegScore) + (0.4 * hrvScore) + (0.2 * voiceScore)
    }

    private func computeEntropy(eeg: EEGReading?, hrv: HRVMetrics?, voice: VoiceFeatures?) -> Double {
        let brainNoise = eeg?.betaGammaChaos ?? 0.0
        let heartFluct = hrv?.entropy ?? 0.0
        let speechJitter = voice?.pauseDisorder ?? 0.0
        return (brainNoise + heartFluct + speechJitter) / 3.0
    }

    private func computeCoherence(eeg: EEGReading?, hrv: HRVMetrics?) -> Double {
        guard let alpha = eeg?.alpha, let hrvCoh = hrv?.coherence else { return 0.0 }
        return (alpha + hrvCoh) / 2.0
    }

    private func computeTruthSignal(eeg: EEGReading?, voice: VoiceFeatures?) -> Double {
        let symbolicAlignment = computeSymbolicMatch(eeg, voice)
        let facialEntropyDrop = voice?.facialConsistencyScore ?? 0.0
        return (0.6 * symbolicAlignment) + (0.4 * facialEntropyDrop)
    }

    private func computeSymbolicMatch(_ eeg: EEGReading?, _ voice: VoiceFeatures?) -> Double {
        // Placeholder: implement symbolic reasoning logic here
        return 0.5
    }

    private func detectDrift() {
        let deltaPsi = psiCurrent - psiPrevious
        if deltaPsi < -0.25 {
            triggerDriftWarning()
        }
    }

    private func triggerDriftWarning() {
        // Activate CDI brake or Guardian mode
        print("Drift detected: Activating CDI Brake or Guardian Mode.")
    }
}
