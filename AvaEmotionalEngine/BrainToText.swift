// BrainToText.swift — Simulated Whisper Forecast Logic
import Foundation

struct SymbolicConstants {
    static let psiThreshold = 1.1
    static let omegaThreshold = 0.9
    static let ksxDriftLimit = 0.25
    static let hrvStabilityLimit = 0.03
}

struct ThoughtResult {
    let decodedText: String
    let confidence: Double
    let symbolicReadiness: Bool
    let classifiers: [String]
    let whisperDecision: WhisperAction
}

class ThoughtMirror {
    func decode(eeg: [Double], hrv: Double) -> ThoughtResult {
        let psi = (eeg[3] + eeg[4]) / (eeg[0] + eeg[1] + 0.01)
        let omega = (eeg[2] * eeg[4]) / (eeg[1] + 0.01)
        let l = 1.0 / (hrv + 0.1)

        let ready = psi > SymbolicConstants.psiThreshold && l > SymbolicConstants.hrvStabilityLimit
        let decision: WhisperAction = ready ? .decode : .deferUntilReady

        return ThoughtResult(
            decodedText: ready ? "I remember you" : "",
            confidence: 0.91,
            symbolicReadiness: ready,
            classifiers: [ready ? "EmergingMemory" : "SuppressedIntent"],
            whisperDecision: decision
        )
    }
}
