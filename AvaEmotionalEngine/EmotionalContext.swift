import Foundation

/// Represents the emotional context used for generating AI responses
struct EmotionalContext {
    let stressLevel: Double           // 0 (calm) to 1 (stressed)
    let emotionalStability: Double    // 0 (volatile) to 1 (stable)
    let emotionalState: EmotionalState
    let trend: EmotionalTrend
    let previousContext: [String]     // Previous conversation turns
}

/// Represents the trend of emotional state
enum EmotionalTrend {
    case increasingStress
    case decreasingStress
    case stable
}
