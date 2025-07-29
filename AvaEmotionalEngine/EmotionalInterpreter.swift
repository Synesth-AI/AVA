import Foundation

enum EmotionalState: String, Codable {
    case calm, slightStress, drift, overload, fatigue
}

enum AVATone: String, Codable {
    case soft, gentle, grounding, protective, soothing
}

struct InterpretationResult: Codable {
    let state: EmotionalState
    let phrase: String
    let tone: AVATone
    
    init(state: EmotionalState, phrase: String, tone: AVATone) {
        self.state = state
        self.phrase = phrase
        self.tone = tone
    }
    
    // Fallback initializer with default values
    init() {
        self.state = .calm
        self.phrase = "I'm here with you."
        self.tone = .soft
    }
}

class EmotionalInterpreter {
    private var lastEntropy: Double = 0.0
    private var lastCoherence: Double = 0.0
    private let aiResponseGenerator = AIResponseGenerator()
    private var conversationHistory: [String] = []
    
    /// Interprets the emotional state and generates a response using AI
    /// - Parameters:
    ///   - entropy: Current entropy value (0-1)
    ///   - coherence: Current coherence value (0-1)
    ///   - integrity: Current integrity value (0-1)
    /// - Returns: Interpretation result with dynamic AI-generated response
    func interpret(entropy: Double, coherence: Double, integrity: Double) -> InterpretationResult {
        // Calculate deltas for trend analysis
        let deltaS = entropy - lastEntropy
        let deltaC = coherence - lastCoherence
        
        // Update state
        lastEntropy = entropy
        lastCoherence = coherence
        
        // Generate AI response
        let response = aiResponseGenerator.generateResponse(
            entropy: entropy,
            coherence: coherence,
            integrity: integrity,
            previousContext: conversationHistory
        )
        
        // Update conversation history
        conversationHistory.append(response)
        if conversationHistory.count > 10 { // Keep last 10 messages
            conversationHistory.removeFirst()
        }
        
        // Determine emotional state based on metrics
        let state = determineEmotionalState(
            entropy: entropy,
            coherence: coherence,
            deltaS: deltaS,
            deltaC: deltaC,
            integrity: integrity
        )
        
        // Determine tone based on state
        let tone = determineTone(for: state)
        
        return InterpretationResult(
            state: state,
            phrase: response,
            tone: tone
        )
    }
    
    // MARK: - Private Helpers
    
    private func determineEmotionalState(entropy: Double, 
                                       coherence: Double, 
                                       deltaS: Double,
                                       deltaC: Double,
                                       integrity: Double) -> EmotionalState {
        // This is a fallback mechanism in case AI generation fails
        if coherence > 0.8 && entropy < 0.2 {
            return .calm
        } else if abs(deltaS) > 0.15 || abs(deltaC) > 0.15 {
            return .drift
        } else if entropy > 0.7 {
            return .overload
        } else if integrity < 0.5 {
            return .fatigue
        } else if entropy > 0.4 {
            return .slightStress
        }
        return .calm
    }
    
    private func determineTone(for state: EmotionalState) -> AVATone {
        switch state {
        case .calm: return .soft
        case .slightStress: return .gentle
        case .drift: return .grounding
        case .overload: return .protective
        case .fatigue: return .soothing
        }
    }
}
