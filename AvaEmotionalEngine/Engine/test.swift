import Foundation

// Data Structures 
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
    let calmMatch: Double
    let pauseDisorder: Double
    let facialConsistencyScore: Double
}

// KXRPEquationBank 
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

// Simulated Receivers and Extractors 
class MuseEEGReceiver {
    func getBandPowers() -> EEGReading {
        // Return random or fixed values for testing
        return EEGReading(
            alpha: Double.random(in: 0.3...1.0),
            theta: Double.random(in: 0.2...0.9),
            beta: Double.random(in: 0.1...0.8),
            gamma: Double.random(in: 0.05...0.7),
            alphaThetaPresence: Double.random(in: 0.2...0.8),
            betaGammaChaos: Double.random(in: 0.1...0.9)
        )
    }
}

class HRVEmulator {
    func getMetrics() -> HRVMetrics {
        // Return random or fixed values for testing
        return HRVMetrics(
            rmssd: Double.random(in: 0.3...0.9),
            sdnn: Double.random(in: 0.2...0.8),
            coherence: Double.random(in: 0.5...1.0),
            entropy: Double.random(in: 0.4...0.95)
        )
    }
}

class VoiceFeatureExtractor {
    func getFeatures() -> VoiceFeatures {
        return VoiceFeatures(
            calmMatch: 0.8, pauseDisorder: 0.2, facialConsistencyScore: 0.9
        )
    }
}

// Computation Functions with Prints
func computePsi(eeg: EEGReading?, hrv: HRVMetrics?, voice: VoiceFeatures?) -> Double {
    let eegScore = eeg?.alphaThetaPresence ?? 0.0
    let hrvScore = hrv?.coherence ?? 0.0
    let voiceScore = voice?.calmMatch ?? 0.0
    let psi = (0.4 * eegScore) + (0.4 * hrvScore) + (0.2 * voiceScore)
    print("computePsi: EEG Score = \(eegScore), HRV Score = \(hrvScore), Voice Score = \(voiceScore) → Psi = \(String(format: "%.4f", psi))")
    return psi
}

func computeEntropy(eeg: EEGReading?, hrv: HRVMetrics?, voice: VoiceFeatures?) -> Double {
    let brainNoise = eeg?.betaGammaChaos ?? 0.0
    let heartFluct = hrv?.entropy ?? 0.0
    let speechJitter = voice?.pauseDisorder ?? 0.0
    let entropy = (brainNoise + heartFluct + speechJitter) / 3.0
    print("computeEntropy: Brain Noise = \(brainNoise), Heart Fluct = \(heartFluct), Speech Jitter = \(speechJitter) → Entropy = \(String(format: "%.4f", entropy))")
    return entropy
}

func computeCoherence(eeg: EEGReading?, hrv: HRVMetrics?) -> Double {
    guard let alpha = eeg?.alpha, let hrvCoh = hrv?.coherence else {
        print("computeCoherence: Missing data → Coherence = 0.0")
        return 0.0
    }
    let coherence = (alpha + hrvCoh) / 2.0
    print("computeCoherence: Alpha = \(alpha), HRV Coh = \(hrvCoh) → Coherence = \(String(format: "%.4f", coherence))")
    return coherence
}

func computeTruthSignal(eeg: EEGReading?, voice: VoiceFeatures?) -> Double {
    let symbolicAlignment = 0.5  // Placeholder for symbolic match (can be expanded)
    let facialEntropyDrop = voice?.facialConsistencyScore ?? 0.0
    let truthSignal = (0.6 * symbolicAlignment) + (0.4 * facialEntropyDrop)
    print("computeTruthSignal: Symbolic Alignment = \(symbolicAlignment), Facial Entropy Drop = \(facialEntropyDrop) → Truth Signal = \(String(format: "%.4f", truthSignal))")
    return truthSignal
}

// Updated Test Function with Dynamic Computations and Prints
func testAllKXRPEquations() {
    let eegReceiver = MuseEEGReceiver()
    let hrvEmulator = HRVEmulator()
    let voiceExtractor = VoiceFeatureExtractor()

    // Simulate previous state for psiPrev
    let prevEeg = eegReceiver.getBandPowers()
    let prevHrv = hrvEmulator.getMetrics()
    let prevVoice = voiceExtractor.getFeatures()
    let psiPrev = computePsi(eeg: prevEeg, hrv: prevHrv, voice: prevVoice)

    // Current state
    let eeg = eegReceiver.getBandPowers()
    let hrv = hrvEmulator.getMetrics()
    let voice = voiceExtractor.getFeatures()
    let entropy = computeEntropy(eeg: eeg, hrv: hrv, voice: voice)
    let coherence = computeCoherence(eeg: eeg, hrv: hrv)
    let truthSignal = computeTruthSignal(eeg: eeg, voice: voice)
    let psi = computePsi(eeg: eeg, hrv: hrv, voice: voice)

    let kxrpBank = KXRPEquationBank()
    var results: [String: Double] = [:]
    for i in 1...50 {
        let result = kxrpBank.computeKXRP(index: i, eeg: eeg, hrv: hrv, voice: voice, entropy: entropy, psi: psi, psiPrev: psiPrev)
        results["KXRP_\(i)"] = result
    }

    let sortedKeys = results.keys.sorted { key1, key2 in
        let num1 = Int(key1.components(separatedBy: "_").last ?? "0") ?? 0
        let num2 = Int(key2.components(separatedBy: "_").last ?? "0") ?? 0
        return num1 < num2
    }

    // Print the sorted results
    for key in sortedKeys {
        if let value = results[key] {
            print("\(key): \(String(format: "%.4f", value))")
    // for (key, value) in results {
    //     print("\(key): \(String(format: "%.4f", value))")
        } 
    }
}

// Run the test
testAllKXRPEquations()
