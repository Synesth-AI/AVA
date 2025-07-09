import Foundation
import AVFoundation

class AVAResponder {
    let synthesizer = AVSpeechSynthesizer()

    func respondIfPermitted(_ allowed: Bool, message: String) {
        if allowed {
            let utterance = AVSpeechUtterance(string: message)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        } else {
            print("AVA: Gating OFF. No response.")
        }
    }
}
