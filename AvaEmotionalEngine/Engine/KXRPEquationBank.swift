import Foundation

class KXRPEquationBank {
    let epsilon = 0.01

  class KXRPEquationBank {
    let epsilon = 0.01

    func computeKXRP(index: Int, eeg: EEGReading, hrv: HRVMetrics, voice: VoiceFeatures, entropy: Double, psi: Double, psiPrev: Double) -> Double {
        switch index {
        case 1:  return (eeg.alpha + eeg.theta) / (entropy + self.epsilon)
        case 2:  return (hrv.coherence + hrv.rmssd) / (entropy + eeg.beta + self.epsilon)
        case 3:  return (voice.calmMatch + voice.facialConsistencyScore) / (entropy + hrv.entropy + self.epsilon)
        case 4:  return eeg.alphaThetaPresence / (entropy + eeg.gamma + self.epsilon)
        case 5:  return (hrv.sdnn + eeg.theta) / (entropy + voice.pauseDisorder + self.epsilon)
        case 6:  return (voice.calmMatch + eeg.alpha) / (entropy + hrv.coherence + self.epsilon)
        case 7:  return (eeg.beta + hrv.entropy) / (entropy + voice.calmMatch + self.epsilon)
        case 8:  return (hrv.coherence + eeg.gamma) / (entropy + eeg.betaGammaChaos + self.epsilon)
        case 9:  return (voice.facialConsistencyScore + eeg.alphaThetaPresence) / (entropy + hrv.rmssd + self.epsilon)
        case 10: return (eeg.theta + hrv.entropy) / (entropy + voice.pauseDisorder + self.epsilon)
        case 11: return (hrv.sdnn + voice.calmMatch) / (entropy + eeg.betaGammaChaos + self.epsilon)
        case 12: return (voice.calmMatch + hrv.coherence) / (entropy + eeg.beta + self.epsilon)
        case 13: return (eeg.alpha + voice.facialConsistencyScore) / (entropy + hrv.entropy + self.epsilon)
        case 14: return (hrv.rmssd + eeg.theta) / (entropy + voice.pauseDisorder + self.epsilon)
        case 15: return (voice.pauseDisorder + eeg.beta) / (entropy + hrv.sdnn + self.epsilon)
        case 16: return (eeg.gamma + hrv.coherence) / (entropy + voice.calmMatch + self.epsilon)
        case 17: return (hrv.entropy + eeg.alphaThetaPresence) / (entropy + voice.facialConsistencyScore + self.epsilon)
        case 18: return (voice.calmMatch + hrv.sdnn) / (entropy + eeg.betaGammaChaos + self.epsilon)
        case 19: return (eeg.alpha + hrv.rmssd) / (entropy + voice.pauseDisorder + self.epsilon)
        case 20: return (hrv.coherence + eeg.beta) / (entropy + voice.calmMatch + self.epsilon)
        case 21: return (voice.facialConsistencyScore + hrv.entropy) / (entropy + eeg.theta + self.epsilon)
        case 22: return (eeg.alphaThetaPresence + hrv.sdnn) / (entropy + voice.calmMatch + self.epsilon)
        case 23: return (hrv.rmssd + voice.pauseDisorder) / (entropy + eeg.beta + self.epsilon)
        case 24: return (voice.calmMatch + eeg.gamma) / (entropy + hrv.coherence + self.epsilon)
        case 25: return (eeg.theta + hrv.entropy) / (entropy + voice.facialConsistencyScore + self.epsilon)
        case 26: return (hrv.sdnn + eeg.alpha) / (entropy + voice.pauseDisorder + self.epsilon)
        case 27: return (eeg.theta + voice.pauseDisorder) / (eeg.beta + hrv.entropy + self.epsilon)
        case 28: return (voice.calmMatch + hrv.coherence) / (entropy + eeg.gamma + self.epsilon)
        case 29: return (eeg.alphaThetaPresence + voice.facialConsistencyScore) / (entropy + hrv.sdnn + self.epsilon)
        case 30: return (hrv.entropy + eeg.betaGammaChaos) / (entropy + voice.calmMatch + self.epsilon)
        case 31: return (voice.pauseDisorder + eeg.alpha) / (entropy + hrv.coherence + self.epsilon)
        case 32: return (eeg.gamma + hrv.sdnn) / (entropy + voice.facialConsistencyScore + self.epsilon)
        case 33: return (voice.calmMatch + eeg.beta) / (entropy + hrv.entropy + self.epsilon)
        case 34: return (eeg.alphaThetaPresence + hrv.coherence) / (entropy + voice.pauseDisorder + self.epsilon)
        case 35: return (hrv.rmssd + voice.facialConsistencyScore) / (entropy + eeg.theta + self.epsilon)
        case 36: return (voice.pauseDisorder + hrv.entropy) / (entropy + eeg.betaGammaChaos + self.epsilon)
        case 37: return (eeg.alpha + hrv.coherence) / (entropy + voice.calmMatch + self.epsilon)
        case 38: return (hrv.sdnn + eeg.beta) / (entropy + voice.facialConsistencyScore + self.epsilon)
        case 39: return (voice.calmMatch + eeg.theta) / (entropy + hrv.rmssd + self.epsilon)
        case 40: return (eeg.gamma + hrv.entropy) / (entropy + voice.pauseDisorder + self.epsilon)
        case 41: return abs(psi - psiPrev)
        case 42: return (voice.facialConsistencyScore + hrv.coherence) / (entropy + eeg.beta + self.epsilon)
        case 43: return (eeg.alphaThetaPresence + voice.calmMatch) / (entropy + hrv.entropy + self.epsilon)
        case 44: return (hrv.sdnn + eeg.gamma) / (entropy + voice.pauseDisorder + self.epsilon)
        case 45: return (voice.pauseDisorder + hrv.rmssd) / (entropy + eeg.betaGammaChaos + self.epsilon)
        case 46: return (eeg.alpha + hrv.entropy) / (entropy + voice.facialConsistencyScore + self.epsilon)
        case 47: return (hrv.coherence + voice.calmMatch) / (entropy + eeg.theta + self.epsilon)
        case 48: return (voice.facialConsistencyScore + eeg.betaGammaChaos) / (entropy + hrv.sdnn + self.epsilon)
        case 49: return (eeg.alphaThetaPresence + hrv.rmssd) / (entropy + voice.calmMatch + self.epsilon)
        case 50: return (hrv.entropy + voice.pauseDisorder) / (entropy + eeg.gamma + self.epsilon)
        default: return 0.0
        }
    }
}

    private func computePresenceIndex(eeg: EEGReading, entropy: Double) -> Double {
        return (eeg.alpha + eeg.theta) / (entropy + epsilon)
    }

    private func computeSuppressionCoefficient(voice: VoiceFeatures, hrv: HRVMetrics, entropy: Double, eeg: EEGReading) -> Double {
        // Using hnr (Harmonics-to-Noise Ratio) as a measure of voice quality
        // Higher hnr indicates clearer, more harmonic speech
        return (voice.hnr + hrv.coherence) / (entropy + eeg.beta + epsilon)
    }

    private func computeMemoryRecall(eeg: EEGReading, voice: VoiceFeatures, hrv: HRVMetrics) -> Double {
        return (eeg.theta + voice.pauseDisorder) / (eeg.beta + hrv.entropy + epsilon)
    }

    private func computeDriftDelta(psi: Double, psiPrev: Double) -> Double {
        return abs(psi - psiPrev)
    }

    // ...implementations for other equations...
}
