import Foundation

/// Determines whether AVA should suppress or emit a whisper
public class WhisperTrigger {
    /// Return true if classifications contain suppression trigger
    public func shouldSuppress(_ classifications: [String]) -> Bool {
        return classifications.contains("Suppressed Emotion")
    }

    /// Hint message when suppression is active
    public func suppressionHint() -> String {
        return "🜃 Symbolic state understood. Output deferred to protect coherence."
    }
}
