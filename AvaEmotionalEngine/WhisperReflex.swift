//
//  WhisperReflex.swift
//  AVAEmotionalEngine
//
//  Created by Isaac Oladele on 08/07/2025.
//

import Foundation

/// Controls the output gating for symbolic processing
public enum WhisperAction: String, Sendable, Equatable {
    /// Allow the message to be processed and spoken
    case decode
    /// Completely suppress the message
    case suppress
    /// Delay processing until conditions are more favorable
    case deferUntilReady
}

/// Manages the whisper reflex system that controls when AVA should speak
public struct WhisperReflex {
    /// Trigger a whisper action with a given reason
    /// - Parameters:
    ///   - action: The whisper action to perform
    ///   - reason: The reason for the action, used for debugging
    public static func trigger(action: WhisperAction, reason: String) {
        print("🟣 Whisper Reflex - Action: \(action.rawValue) | Reason: \(reason)")
    }
}
