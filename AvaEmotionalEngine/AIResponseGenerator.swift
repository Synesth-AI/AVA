import Foundation
import NaturalLanguage
import Combine

// Import the shared model

// MARK: - Response Templates

struct ResponseTemplates {
    static let calmResponses = [
        "I sense a beautiful calmness around you. How can I support you today?",
        "Your energy feels balanced and centered. What's on your mind?",
        "I notice a peaceful presence. Is there something you'd like to explore together?",
        "Your calm energy is refreshing. How are you feeling in this moment?"
    ]
    
    static let stressResponses = [
        "I sense some tension. Would you like to take a moment to breathe with me?",
        "I notice things feel a bit intense. Let's find some grounding together.",
        "Your energy suggests you might be carrying some weight. Would it help to talk about it?",
        "I'm picking up on some stress. Let's slow things down a bit."
    ]
    
    static let driftResponses = [
        "I notice your thoughts might be wandering. Would you like to come back to the present with me?",
        "Let's take a deep breath together and find our center.",
        "I'm here to help you stay grounded. What's one thing you can see right now?",
        "Your energy feels a bit scattered. Let's find our focus together."
    ]
    
    static let overloadResponses = [
        "I'm here with you. Let's take a moment to pause and breathe.",
        "You're not alone in this. I'm right here with you.",
        "Let's slow everything down. One breath at a time.",
        "I can see this is a lot. Would it help to focus on just one thing right now?"
    ]
    
    static let fatigueResponses = [
        "It's okay to rest. You don't have to push through everything.",
        "I notice you might need some gentle care right now. How can I support you?",
        "Your energy feels low. Would it help to take a short break?",
        "Sometimes the most powerful thing we can do is rest. What do you need right now?"
    ]
    
    static let transitionPhrases = [
        "I'm here with you.",
        "Let's take a moment together.",
        "I'm listening.",
        "Take your time.",
        "I'm right here.",
        "You're not alone in this."
    ]
}

// MARK: - Emotional Context Extension

extension EmotionalContext {
    var responseBase: [String] {
        switch self.emotionalState {
        case .calm: return ResponseTemplates.calmResponses
        case .slightStress: return ResponseTemplates.stressResponses
        case .drift: return ResponseTemplates.driftResponses
        case .overload: return ResponseTemplates.overloadResponses
        case .fatigue: return ResponseTemplates.fatigueResponses
        }
    }
    
    var shouldUseTransition: Bool {
        // 30% chance to use a transition phrase
        return Double.random(in: 0...1) < 0.3
    }
    
    var transitionPhrase: String {
        return ResponseTemplates.transitionPhrases.randomElement() ?? ""
    }
}

class AIResponseGenerator {
    private let contextManager = ConversationContextManager()
    private var lastResponse: String = ""
    private var cloudService: CloudAIService?
    private var cancellables = Set<AnyCancellable>()
    
    /// Initialize with optional cloud API key
    init(cloudAPIKey: String? = nil) {
        if let apiKey = cloudAPIKey, !apiKey.isEmpty {
            self.cloudService = CloudAIService(apiKey: apiKey, localFallback: self)
            print("AIResponseGenerator: Cloud AI service initialized")
        } else {
            print("AIResponseGenerator: Running in local-only mode")
        }
    }
    
    /// Generates a contextual response based on emotional metrics
    /// - Parameters:
    ///   - entropy: Current entropy value (0-1)
    ///   - coherence: Current coherence value (0-1)
    ///   - integrity: Current integrity value (0-1)
    ///   - previousContext: Array of previous messages for context
    ///   - completion: Called with the generated response (for async cloud requests)
    func generateResponse(entropy: Double,
                         coherence: Double,
                         integrity: Double,
                         previousContext: [String] = [],
                         completion: ((String) -> Void)? = nil) -> String {
        
        // Update context with new metrics
        let context = contextManager.updateAndGetContext(
            entropy: entropy,
            coherence: coherence,
            integrity: integrity,
            previousContext: previousContext
        )
        
        // If we have a cloud service and a completion handler, use async cloud processing
        if let cloudService = cloudService, completion != nil {
            // Generate response asynchronously with cloud service
            cloudService.generateResponse(context: context) { [weak self] cloudResponse in
                guard let self = self else { return }
                
                // Update last response and call completion
                self.lastResponse = cloudResponse
                completion?(cloudResponse)
            }
            
            // Return a temporary response while waiting for cloud
            return "I'm here with you..."
        }
        
        // Otherwise, use local processing
        let response: String
        if #available(iOS 15.0, *), let nlpResponse = generateWithBuiltInNLP(context: context) {
            response = nlpResponse
        } else {
            response = generateFallbackResponse(context: context)
        }
        
        // Ensure we don't repeat the same response
        let finalResponse: String
        if response == lastResponse && !context.responseBase.isEmpty {
            finalResponse = getVariedResponse(for: context, excluding: response)
        } else {
            finalResponse = response
        }
        
        lastResponse = finalResponse
        return finalResponse
    }
    
    private func getVariedResponse(for context: EmotionalContext, excluding response: String) -> String {
        let possibleResponses = context.responseBase.filter { $0 != response }
        
        if possibleResponses.isEmpty {
            return response // Return the original if no alternatives
        }
        
        var selectedResponse = possibleResponses.randomElement() ?? response
        
        // Add a transition phrase 30% of the time for variety
        if context.shouldUseTransition {
            let transition = context.transitionPhrase
            if !transition.isEmpty {
                selectedResponse = "\(transition) \(selectedResponse)"
            }
        }
        
        return selectedResponse
    }
    
    @available(iOS 15.0, *)
    private func generateWithBuiltInNLP(context: EmotionalContext) -> String? {
        // Use Apple's built-in NL framework for text analysis
        let tagger = NLTagger(tagSchemes: [.sentimentScore, .tokenType])
        
        // Create a prompt based on emotional state and previous context
        let prompt = createPrompt(from: context)
        tagger.string = prompt
        
        // Get the sentiment score from the prompt
        var sentiment: NLTag? = nil
        let range = prompt.startIndex..<prompt.endIndex
        
        tagger.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore, options: []) { (tag, _) in
            sentiment = tag
            return true
        }
        
        // Generate a response that's aware of the emotional context
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
        // Start with a base response based on emotional state
        var responses = context.responseBase
        
        // If we have previous context, try to be more specific
        if !context.previousContext.isEmpty {
            let lastMessage = context.previousContext.last ?? ""
            
            // Check for specific keywords in the last message
            let lowercased = lastMessage.lowercased()
            
            if lowercased.contains("scared") || lowercased.contains("afraid") {
                responses = [
                    "It's okay to feel scared. I'm here with you.",
                    "Fear can be overwhelming. Let's breathe through this together.",
                    "I hear that you're feeling scared. You're not alone in this."
                ]
            } else if lowercased.contains("angry") || lowercased.contains("mad") {
                responses = [
                    "Anger is a valid emotion. Would it help to talk about what's coming up for you?",
                    "I hear your anger. Let's find a way to channel this energy.",
                    "Anger often points to something important. What's beneath this feeling?"
                ]
            } else if lowercased.contains("sad") || lowercased.contains("upset") {
                responses = [
                    "I'm here with you in this sadness. You don't have to carry it alone.",
                    "Your sadness is welcome here. Would you like to share more?",
                    "It's okay to feel down sometimes. I'm right here with you."
                ]
            }
        }
        
        // Select a random response from the available options
        var selectedResponse = responses.randomElement() ?? "I'm here with you."
        
        // Sometimes add a transition phrase for variety
        if context.shouldUseTransition {
            selectedResponse = "\(context.transitionPhrase) \(selectedResponse)"
        }
        
        return selectedResponse
    }
    
    func generateFallbackResponse(context: EmotionalContext) -> String {
        // Use the local response generation logic
        let response: String
        if #available(iOS 15.0, *), let nlpResponse = generateWithBuiltInNLP(context: context) {
            response = nlpResponse
        } else {
            // Simple fallback responses based on emotional state
            switch context.emotionalState {
            case .calm:
                response = "I'm here with you. How can I support you today?"
            case .slightStress:
                response = "I notice some tension. Would you like to take a deep breath with me?"
            case .drift:
                response = "Let's find our center together. What's one thing you can see right now?"
            case .overload:
                response = "I'm here with you. Let's take this one moment at a time."
            case .fatigue:
                response = "It's okay to rest. I'm here with you."
            }
        }
        
        // Ensure we don't repeat the same response
        if response == lastResponse && !context.responseBase.isEmpty {
            return getVariedResponse(for: context, excluding: response)
        }
        
        lastResponse = response
        return response
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
        
        // Determine the emotional state based on stress level
        let emotionalState: EmotionalState = {
            switch stressLevel {
            case 0..<0.2: return .calm
            case 0.2..<0.4: return .slightStress
            case 0.4..<0.6: return .drift
            case 0.6..<0.8: return .overload
            default: return .fatigue
            }
        }()
        
        return EmotionalContext(
            stressLevel: stressLevel,
            emotionalStability: coherence,
            emotionalState: emotionalState,
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

// EmotionalContext and related types moved to EmotionalContext.swift
