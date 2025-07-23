import Foundation
import AVFoundation

import Foundation
import AVFoundation

class AVAResponder {
    let synthesizer = AVSpeechSynthesizer()
    private let interpreter = EmotionalInterpreter()

    // Main function: generate and speak response based on metrics
    func respondBasedOnMetrics(psi: Double, entropy: Double, coherence: Double, integrity: Double, kxrpValues: [Int: Double], gating: Bool = true) {
        let result = interpreter.interpret(entropy: entropy, coherence: coherence, integrity: integrity)
        let isFallback = result.state == .calm // You can refine fallback logic if needed
        if !gating || !isFallback {
            speak(message: result.phrase, tone: result.tone)
        } else {
            print("AVA: Gating failed. Remaining silent to respect emotional state.")
        }
    }

    // Helper: speak the message with tone adjustment
    private func speak(message: String, tone: AVATone) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // Adjust rate/pitch based on tone (expand as needed)
        switch tone {
        case .soft: utterance.rate = 0.48; utterance.pitchMultiplier = 1.0
        case .gentle: utterance.rate = 0.45; utterance.pitchMultiplier = 1.05
        case .grounding: utterance.rate = 0.50; utterance.pitchMultiplier = 0.98
        case .protective: utterance.rate = 0.42; utterance.pitchMultiplier = 0.95
        case .soothing: utterance.rate = 0.40; utterance.pitchMultiplier = 0.98
        }
        synthesizer.speak(utterance)
        print("AVA: \(message)")
    }
}

