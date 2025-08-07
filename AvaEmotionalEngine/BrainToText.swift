// BrainToText.swift — Simulated Whisper Forecast Logic
import Foundation

struct SymbolicConstants {
    static let psiThreshold = 1.1
    static let omegaThreshold = 0.9
    static let ksxDriftLimit = 0.25
    static let hrvStabilityLimit = 0.03
}

public struct ThoughtResult {
    public let decodedText: String
    public let confidence: Double
    public let symbolicReadiness: Bool
    public let classifiers: [String]
    public let whisperDecision: WhisperAction
    
    public init(decodedText: String, confidence: Double, symbolicReadiness: Bool, classifiers: [String], whisperDecision: WhisperAction) {
        self.decodedText = decodedText
        self.confidence = confidence
        self.symbolicReadiness = symbolicReadiness
        self.classifiers = classifiers
        self.whisperDecision = whisperDecision
    }
}

public class ThoughtMirror {
    public init() {}
    
    public func decode(eeg: [Double], hrv: Double) -> ThoughtResult {
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
