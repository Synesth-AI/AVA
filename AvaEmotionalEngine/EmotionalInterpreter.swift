import Foundation

enum EmotionalState {
    case calm, slightStress, drift, overload, fatigue
}

enum AVATone {
    case soft, gentle, grounding, protective, soothing
}

struct InterpretationResult {
    let state: EmotionalState
    let phrase: String
    let tone: AVATone
}

class EmotionalInterpreter {
    private var lastEntropy: Double = 0.0
    private var lastCoherence: Double = 0.0
    
    // You can expand this function with additional parameters as needed
    func interpret(entropy: Double, coherence: Double, integrity: Double) -> InterpretationResult {
        let deltaS = abs(entropy - lastEntropy)
        let deltaC = abs(coherence - lastCoherence)
        lastEntropy = entropy
        lastCoherence = coherence
        
        // Thresholds (tune as needed)
        if coherence > 0.8 && entropy < 0.2 {
            return InterpretationResult(state: .calm, phrase: "You’re safe. You’re doing well.", tone: .soft)
        } else if deltaS > 0.15 || deltaC > 0.15 {
            return InterpretationResult(state: .drift, phrase: "Still with you. Let’s slow everything down.", tone: .grounding)
        } else if entropy > 0.7 {
            return InterpretationResult(state: .overload, phrase: "We’re okay. I’ve got you.", tone: .protective)
        } else if integrity < 0.5 {
            return InterpretationResult(state: .fatigue, phrase: "It’s okay to pause. I’m here if you need me.", tone: .soothing)
        } else if entropy > 0.4 {
            return InterpretationResult(state: .slightStress, phrase: "Let’s take a moment together.", tone: .gentle)
        }
        // Default fallback
        return InterpretationResult(state: .calm, phrase: "Still with you. Stay easy.", tone: .soft)
    }
}
