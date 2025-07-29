import Foundation
import CoreML
import NaturalLanguage

class AIResponseGenerator {
    private let contextManager = ConversationContextManager()
    
    /// Generates a contextual response based on emotional metrics
    func generateResponse(entropy: Double, 
                         coherence: Double, 
                         integrity: Double,
                         previousContext: [String] = []) -> String {
        
        // Update context with new metrics
        let context = contextManager.updateAndGetContext(
            entropy: entropy,
            coherence: coherence,
            integrity: integrity,
            previousContext: previousContext
        )
        
        // Use the most appropriate model based on available resources
        if #available(iOS 15.0, *), let response = generateWithBuiltInNLP(context: context) {
            return response
        } else {
            // Fallback to rule-based responses if ML is not available
            return generateFallbackResponse(context: context)
        }
    }
    
    @available(iOS 15.0, *)
    private func generateWithBuiltInNLP(context: EmotionalContext) -> String? {
        // Use Apple's built-in NL framework for text generation
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        
        // Create a prompt based on emotional state
        let prompt = createPrompt(from: context)
        tagger.string = prompt
        
        // Get sentiment score (range from -1 to 1)
        let (sentiment, _) = tagger.tag(at: prompt.startIndex, 
                                      unit: .paragraph, 
                                      scheme: .sentimentScore)
        
        // Generate response based on sentiment and emotional state
        return generateResponse(from: context, sentiment: sentiment)
    }
    
    private func createPrompt(from context: EmotionalContext) -> String {
        """
        User's emotional state:
        - Stress Level: \(context.stressLevel)
        - Emotional Stability: \(context.emotionalStability)
        - Recent Trend: \(context.trend)
        - Previous Context: \(context.previousContext.joined(separator: "; "))
        
        Generate a supportive, empathetic response that acknowledges their state and helps them feel understood. 
        Response should be brief (1-2 sentences) and in a calm, reassuring tone.
        """
    }
    
    private func generateResponse(from context: EmotionalContext, sentiment: NLTag?) -> String {
        // You can expand this with more sophisticated response generation
        // For now, we'll use a simple switch based on stress level
        switch context.stressLevel {
        case 0..<0.3:
            return "I notice you're feeling quite balanced. That's wonderful to see. How can I support you today?"
        case 0.3..<0.7:
            return "I'm sensing some tension. Would it help to take a few deep breaths together?"
        default:
            return "I can see this is a challenging moment. I'm here with you. Would you like to talk about what's coming up?"
        }
    }
    
    private func generateFallbackResponse(context: EmotionalContext) -> String {
        // Simple fallback responses when ML is not available
        if context.trend == .increasingStress {
            return "I notice things are feeling more intense. Would you like to try a grounding exercise?"
        } else if context.trend == .decreasingStress {
            return "I can see you're finding some calm. That's great progress."
        } else {
            return "I'm here with you. How can I support you right now?"
        }
    }
}

// MARK: - Supporting Types

private class ConversationContextManager {
    private var previousMetrics: [(entropy: Double, coherence: Double, integrity: Double)] = []
    private let maxContextLength = 5
    
    func updateAndGetContext(entropy: Double, 
                           coherence: Double, 
                           integrity: Double,
                           previousContext: [String]) -> EmotionalContext {
        
        // Update metrics history
        previousMetrics.append((entropy, coherence, integrity))
        if previousMetrics.count > 10 { // Keep last 10 readings
            previousMetrics.removeFirst()
        }
        
        // Calculate trend
        let trend: EmotionalTrend = previousMetrics.count > 1 ? 
            calculateTrend() : .stable
        
        // Calculate stress level (simplified example)
        let stressLevel = min(1.0, max(0.0, (entropy * 0.6) + ((1 - coherence) * 0.4)))
        
        return EmotionalContext(
            stressLevel: stressLevel,
            emotionalStability: coherence,
            trend: trend,
            previousContext: Array(previousContext.suffix(maxContextLength))
        )
    }
    
    private func calculateTrend() -> EmotionalTrend {
        guard previousMetrics.count >= 3 else { return .stable }
        
        let recent = previousMetrics.suffix(3)
        let first = recent.first!
        let last = recent.last!
        
        let entropyChange = last.entropy - first.entropy
        let coherenceChange = last.coherence - first.coherence
        
        if abs(entropyChange) < 0.1 && abs(coherenceChange) < 0.1 {
            return .stable
        } else if entropyChange > 0.1 || coherenceChange < -0.1 {
            return .increasingStress
        } else {
            return .decreasingStress
        }
    }
}

private struct EmotionalContext {
    let stressLevel: Double           // 0 (calm) to 1 (stressed)
    let emotionalStability: Double    // 0 (volatile) to 1 (stable)
    let trend: EmotionalTrend
    let previousContext: [String]     // Previous conversation turns
}

private enum EmotionalTrend {
    case increasingStress
    case decreasingStress
    case stable
}
