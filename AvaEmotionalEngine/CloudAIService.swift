import Foundation
import Combine
import Network

class CloudAIService {
    private let apiKey: String
    private let session: URLSession
    private let localFallback: AIResponseGenerator
    
    init(apiKey: String, localFallback: AIResponseGenerator) {
        self.apiKey = apiKey
        self.localFallback = localFallback
        self.session = URLSession(configuration: .default)
    }
    
    /// Generates a response using cloud AI with local fallback
    func generateResponse(context: EmotionalContext, 
                         completion: @escaping (String) -> Void) {
        // First check network connectivity
        guard NetworkMonitor.shared.isConnected else {
            print("CloudAIService: Offline - Using local fallback")
            completion(localFallback.generateFallbackResponse(context: context))
            return
        }
        
        // Prepare the prompt for the AI
        let prompt = createPrompt(from: context)
        
        // Create the API request
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the request body
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are AVA, an empathetic AI assistant that helps users with emotional regulation and support. Keep responses brief (1-2 sentences), warm, and supportive."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 100
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("CloudAIService: Error creating request: \(error)")
            completion(localFallback.generateFallbackResponse(context: context))
            return
        }
        
        // Make the API call
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("CloudAIService: API error: \(error.localizedDescription)")
                self.fallbackToLocal(context: context, completion: completion)
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("CloudAIService: Invalid response format")
                self.fallbackToLocal(context: context, completion: completion)
                return
            }
            
            // Return the AI's response
            DispatchQueue.main.async {
                completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        task.resume()
    }
    
    private func fallbackToLocal(context: EmotionalContext, completion: @escaping (String) -> Void) {
        print("CloudAIService: Falling back to local AI")
        let response = localFallback.generateFallbackResponse(context: context)
        DispatchQueue.main.async {
            completion(response)
        }
    }
    
    private func createPrompt(from context: EmotionalContext) -> String {
        """
        The user is currently experiencing the following emotional state:
        - Stress Level: \(context.stressLevel * 100)%
        - Emotional Stability: \(context.emotionalStability * 100)%
        - Current State: \(context.emotionalState.rawValue)
        - Recent Trend: \(context.trend)
        
        Previous conversation context:
        \(context.previousContext.joined(separator: "\n"))
        
        Please provide a brief, empathetic response that acknowledges their current state and offers support.
        """
    }
}

// Network monitoring
class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    private init() {
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    deinit {
        monitor.cancel()
    }
}
