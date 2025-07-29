import Foundation
import AVFoundation
import Combine

class AVAResponder: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    // MARK: - Properties
    private let synthesizer = AVSpeechSynthesizer()
    private let interpreter: EmotionalInterpreter
    private let aiGenerator: AIResponseGenerator
    private var cancellables = Set<AnyCancellable>()
    private var isFallback = false
    
    // MARK: - Published Properties
    @Published private(set) var isSpeaking = false
    @Published private(set) var currentResponse: String = ""
    
    // MARK: - Initialization
    init(aiGenerator: AIResponseGenerator) {
        self.aiGenerator = aiGenerator
        self.interpreter = EmotionalInterpreter()
        super.init()
        print("AVAResponder: Initializing with AI generator")
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

    // MARK: - Response Generation
    
    /// Main function: generate and speak response based on metrics
    func respondBasedOnMetrics(psi: Double, entropy: Double, coherence: Double, integrity: Double, kxrpValues: [Int: Double], gating: Bool = true) {
        print("AVAResponder: Received request to speak")
        
        // Use the AI generator to get a response
        let response = aiGenerator.generateResponse(
            entropy: entropy,
            coherence: coherence,
            integrity: integrity,
            previousContext: interpreter.conversationHistory
        ) { [weak self] aiResponse in
            // This closure is called when the cloud response is ready
            DispatchQueue.main.async {
                self?.speakAIResponse(aiResponse)
            }
        }
        
        // If we got an immediate response (local AI), speak it
        if !response.isEmpty {
            isFallback = false
            speakAIResponse(response)
        } else {
            // If no immediate response, use the interpreter to generate a fallback response
            isFallback = true
            if !gating {
                // Use the interpreter to get a fallback response
                let interpretation = interpreter.interpret(entropy: entropy, coherence: coherence, integrity: integrity)
                print("AVAResponder: Speaking fallback: \(interpretation.phrase)")
                speak(message: interpretation.phrase, tone: interpretation.tone)
            } else {
                print("AVAResponder: Gating prevented speech")
            }
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
    
    // MARK: - Speech Handling
    
    private func speakAIResponse(_ response: String) {
        guard !response.isEmpty else {
            print("AVAResponder: Empty AI response received")
            return
        }
        
        // Update the current response
        currentResponse = response
        
        // Determine the appropriate tone based on the emotional state
        let tone: Float = 1.0 // Default tone, can be adjusted based on emotional state
        
        // Speak the response
        speak(message: response, tone: tone)
    }
    
    private func speak(message: String, tone: Float) {
        guard !message.isEmpty else {
            print("AVAResponder: Empty message received, not speaking")
            return
        }
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = tone
        utterance.volume = 1.0
        
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Update speaking state
        isSpeaking = true
        
        // Speak the message
        print("AVAResponder: Attempting to speak: \"\(message)\"")
        synthesizer.speak(utterance)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("AVAResponder: Finished speaking")
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("AVAResponder: Started speaking")
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("AVAResponder: Speech paused")
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("AVAResponder: Speech continued")
        isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let startIndex = utterance.speechString.index(utterance.speechString.startIndex, offsetBy: characterRange.location)
        let endIndex = utterance.speechString.index(startIndex, offsetBy: characterRange.length)
        let substring = String(utterance.speechString[startIndex..<endIndex])
        print("AVAResponder: Will speak: \"\(substring)\"")
    }
}

