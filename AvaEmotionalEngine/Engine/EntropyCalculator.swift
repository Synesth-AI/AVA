import Foundation

class EntropyCalculator {
    private(set) var entropy: Double = 0.0
    private(set) var coherence: Double = 0.0
    private var entropyHistory: [Double] = []
    private let maxHistory: Int = 300

    func update(eeg: EEGReading?, hrv: HRVMetrics?, voice: VoiceFeatures?) {
        entropy = computeEntropy(eeg: eeg, hrv: hrv, voice: voice)
        coherence = computeCoherence(eeg: eeg, hrv: hrv)
        trackHistory(entropy)
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

    private func trackHistory(_ value: Double) {
        entropyHistory.append(value)
        if entropyHistory.count > maxHistory {
            entropyHistory.removeFirst()
        }
    }

    func entropyDelta() -> Double {
        guard entropyHistory.count >= 2 else { return 0.0 }
        return entropyHistory.last! - entropyHistory[entropyHistory.count - 2]
    }

    func movingAverage(window: Int = 5) -> Double {
        let count = min(window, entropyHistory.count)
        guard count > 0 else { return 0.0 }
        return entropyHistory.suffix(count).reduce(0, +) / Double(count)
    }
}
