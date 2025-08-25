import Foundation
import Combine
import Network

enum CloudModelProvider {
    case openAI(model: String)
    case deepSeek(model: String)
}

class CloudAIService {
    private let apiKey: String
    private let session: URLSession
    private let localFallback: AIResponseGenerator
    private let provider: CloudModelProvider
    private let enableGPT5Preview: Bool

    init(apiKey: String,
         localFallback: AIResponseGenerator,
         provider: CloudModelProvider = .openAI(model: "gpt-4o-mini"),
         enableGPT5Preview: Bool = false,
         timeout: TimeInterval = 30.0) {
        self.apiKey = apiKey
        self.localFallback = localFallback
        self.provider = enableGPT5Preview ? .openAI(model: "gpt-5-preview") : provider
        self.enableGPT5Preview = enableGPT5Preview
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        self.session = URLSession(configuration: config)
        if apiKey.isEmpty { print("CloudAIService WARN: API key is empty") }
    }

    /// Generates a response using cloud AI with local fallback
    func generateResponse(context: EmotionalContext,
                          completion: @escaping (String) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            print("CloudAIService: Offline - Using local fallback")
            completion(localFallback.generateFallbackResponse(context: context))
            return
        }
        let prompt = createPrompt(from: context)
        let (url, modelHeader, authHeader) = endpointInfo()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = requestBody(model: modelHeader, prompt: prompt)
        do { request.httpBody = try JSONSerialization.data(withJSONObject: body) } catch {
            print("CloudAIService: JSON encode error: \(error)")
            fallbackToLocal(context: context, completion: completion)
            return
        }

        let started = Date()
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                print("CloudAIService: Transport error: \(error)")
                self.fallbackToLocal(context: context, completion: completion)
                return
            }
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            guard let data else {
                print("CloudAIService: Empty response body (status=\(status))")
                self.fallbackToLocal(context: context, completion: completion)
                return
            }
            guard (200...299).contains(status) else {
                let snippet = String(data: data.prefix(500), encoding: .utf8) ?? "<non-utf8>"
                print("CloudAIService: HTTP \(status) body: \(snippet)")
                self.fallbackToLocal(context: context, completion: completion)
                return
            }
            if let text = self.extractContent(from: data) {
                let latency = String(format: "%.2fs", Date().timeIntervalSince(started))
                print("CloudAIService: Success (latency=\(latency))")
                DispatchQueue.main.async { completion(text) }
            } else {
                print("CloudAIService: Parse failure raw=\(String(data: data, encoding: .utf8) ?? "<decode fail>")")
                self.fallbackToLocal(context: context, completion: completion)
            }
        }
        task.resume()
    }

    private func requestBody(model: String, prompt: String) -> [String: Any] {
        switch provider {
        case .openAI:
            return [
                "model": model,
                "messages": [
                    ["role": "system", "content": "You are AVA, an empathetic AI assistant that helps users with emotional regulation and support. Keep responses brief (1-2 sentences), warm, and supportive."],
                    ["role": "user", "content": prompt]
                ],
                "temperature": 0.7,
                "max_tokens": 120
            ]
        case .deepSeek:
            // DeepSeek style is similar to OpenAI Chat; adjust keys if API differs
            return [
                "model": model,
                "messages": [
                    ["role": "system", "content": "You are AVA, an empathetic AI assistant that helps users with emotional regulation and support. Keep responses brief (1-2 sentences), warm, and supportive."],
                    ["role": "user", "content": prompt]
                ],
                "temperature": 0.7,
                "max_tokens": 120
            ]
        }
    }

    private func endpointInfo() -> (URL, String, String) {
        switch provider {
        case .openAI(let model):
            return (URL(string: "https://api.openai.com/v1/chat/completions")!, model, "Bearer \(apiKey)")
        case .deepSeek(let model):
            return (URL(string: "https://api.deepseek.com/v1/chat/completions")!, model, "Bearer \(apiKey)")
        }
    }

    private func extractContent(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first else { return nil }
        if let msg = first["message"] as? [String: Any] {
            if let content = msg["content"] as? String { return content.trimmingCharacters(in: .whitespacesAndNewlines) }
            if let parts = msg["content"] as? [[String: Any]] {
                let joined = parts.compactMap { $0["text"] as? String }.joined(separator: " ")
                return joined.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        if let text = first["text"] as? String { // some providers use 'text'
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    private func fallbackToLocal(context: EmotionalContext, completion: @escaping (String) -> Void) {
        print("CloudAIService: Falling back to local AI")
        let response = localFallback.generateFallbackResponse(context: context)
        DispatchQueue.main.async { completion(response) }
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

        Provide a brief (<= 2 sentences), emotionally validating, hopeful response.
        """
    }
}

// Network monitoring with cached state
class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var _connected: Bool = false
    var isConnected: Bool { _connected }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let status = path.status == .satisfied
            if status != self?._connected { print("NetworkMonitor: now \(status ? "online" : "offline")") }
            self?._connected = status
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
