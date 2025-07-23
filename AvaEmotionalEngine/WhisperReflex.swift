// WhisperReflex.swift — Symbolic Output Gate
import Foundation

enum WhisperAction: String {
    case decode, suppress, deferUntilReady
}

struct WhisperReflex {
    static func trigger(action: WhisperAction, reason: String) {
        print("🟣 Whisper Reflex Triggered — Action: \(action.rawValue) | Reason: \(reason)")
    }
}
