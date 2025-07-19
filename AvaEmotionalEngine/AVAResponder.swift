import Foundation
import AVFoundation

class AVAResponder {
    let synthesizer = AVSpeechSynthesizer()

    // Main function: generate and speak response based on metrics and KXRP values
    func respondBasedOnMetrics(psi: Double, entropy: Double, coherence: Double, integrity: Double, kxrpValues: [Int: Double], gating: Bool = true) {
        let message = generateMessage(psi: psi, entropy: entropy, coherence: coherence, integrity: integrity, kxrpValues: kxrpValues)
        let isFallback = message == "Emotional field is balanced. How are you feeling right now?"
        if !gating || !isFallback {
            speak(message: message)
        } else {
            print("AVA: Gating failed. Remaining silent to respect emotional state.")
        }
    }

    // Expanded: generate dynamic message incorporating KXRP values
    func generateMessage(psi: Double, entropy: Double, coherence: Double, integrity: Double, kxrpValues: [Int: Double]) -> String {
        // Base responses from core metrics
        if psi > 0.8 && entropy < 0.2 && coherence > 0.7 && integrity > 0.8 {
            return "Emotional field is stable and aligned. You're in a strong, present state."
        } else if psi > 0.7 && entropy > 0.4 {
            return "I sense some rising inner noise. Take a moment to breathe with me?"
        } else if coherence < 0.5 {
            return "Your signals feel a bit out of sync. Let's pause and recenter."
        } else if integrity < 0.5 {
            return "Something feels off in the emotional alignment. Is this true for you?"
        } else if psi > 0.5 && entropy < 0.4 {
            return "You're holding steady. I'm here if you need grounding."
        }

        // Additional responses based on specific KXRP values
        if let kxrp1 = kxrpValues[1], kxrp1 > 0.8 {
            return "Your presence feels strong and grounded. Let's build on that calm focus."
        } else if let kxrp12 = kxrpValues[12], kxrp12 > 0.7 {
            return "It seems like something might be held back. Would you like to share in your own time?"
        } else if let kxrp27 = kxrpValues[27], kxrp27 > 0.6 {
            return "Memories may be surfacing. Take it gently—I'm here to listen without judgment."
        } else if let kxrp41 = kxrpValues[41], kxrp41 > 0.5 {
            return "I notice a shift in your emotional flow. Let's slow down and check in."
        } else if let kxrp7 = kxrpValues[7], kxrp7 > 0.7 {
            return "Stress seems to be building. How about a quick reset to ease the load?"
        } else if let kxrp30 = kxrpValues[30], kxrp30 > 0.6 {
            return "There's some inner turbulence. Let's find a steady rhythm together."
        }

        // Default fallback
        return "Emotional field is balanced. How are you feeling right now?"
    }

    // Helper: speak the message
    private func speak(message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5  // Slower for calm delivery
        synthesizer.speak(utterance)
        print("AVA: \(message)")
    }
}
