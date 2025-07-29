import Foundation
import AVFoundation

class AVAResponder: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private let interpreter = EmotionalInterpreter()
    
    override init() {
        super.init()
        print("AVAResponder: Initializing...")
        synthesizer.delegate = self
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("AVAResponder: Audio session set up successfully")
        } catch {
            print("AVAResponder: Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    // Main function: generate and speak response based on metrics
    func respondBasedOnMetrics(psi: Double, entropy: Double, coherence: Double, integrity: Double, kxrpValues: [Int: Double], gating: Bool = true) {
        print("AVAResponder: Received request to speak")
        
        // Get the response from interpreter
        let result = interpreter.interpret(entropy: entropy, coherence: coherence, integrity: integrity)
        let isFallback = result.state == .calm
        
        if !gating || !isFallback {
            print("AVAResponder: Speaking: \(result.phrase)")
            speak(message: result.phrase, tone: result.tone)
        } else {
            print("AVAResponder: Gating prevented speech")
        }
    }

    // Helper: speak the message with tone adjustment
    private func speak(message: String, tone: AVATone) {
        print("AVAResponder: Preparing to speak: \"\(message)\"")
        
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            print("AVAResponder: Stopping current speech")
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Create the utterance
        let utterance = AVSpeechUtterance(string: message)
        
        // Set the voice - explicitly get the default voice
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
            print("AVAResponder: Using voice: \(voice.identifier)")
        } else {
            print("AVAResponder: Warning: Could not get en-US voice")
        }
        
        // Set volume and other properties
        utterance.volume = 1.0  // Full volume (0.0 to 1.0)
        
        // Adjust rate/pitch based on tone
        switch tone {
        case .soft: 
            utterance.rate = 0.48
            utterance.pitchMultiplier = 1.0
        case .gentle: 
            utterance.rate = 0.45
            utterance.pitchMultiplier = 1.05
        case .grounding: 
            utterance.rate = 0.50
            utterance.pitchMultiplier = 0.98
        case .protective: 
            utterance.rate = 0.42
            utterance.pitchMultiplier = 0.95
        case .soothing: 
            utterance.rate = 0.40
            utterance.pitchMultiplier = 0.98
        }
        
        print("AVAResponder: Speaking with rate: \(utterance.rate), pitch: \(utterance.pitchMultiplier)")
        
        // Speak on the main thread
        DispatchQueue.main.async {
            do {
                print("AVAResponder: Activating audio session")
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                print("AVAResponder: Starting speech synthesis")
                self.synthesizer.speak(utterance)
                print("AVAResponder: Speak method called")
            } catch {
                print("AVAResponder: Error in speak: \(error.localizedDescription)")
            }
        }
    }
    
    // Public: speak any message in a neutral/soft tone (for symbolic memory)
    func speakRaw(message: String) {
        print("AVAResponder: Speaking raw message")
        speak(message: message, tone: .soft)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("AVAResponder: Did start speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("AVAResponder: Did finish speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("AVAResponder: Did pause speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("AVAResponder: Did continue speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("AVAResponder: Did cancel speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let startIndex = utterance.speechString.index(utterance.speechString.startIndex, offsetBy: characterRange.location)
        let endIndex = utterance.speechString.index(startIndex, offsetBy: characterRange.length)
        let substring = String(utterance.speechString[startIndex..<endIndex])
        print("AVAResponder: Will speak: \"\(substring)\"")
    }
}

