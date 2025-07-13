import Foundation

// MARK: - Data Models

/// Represents EEG reading data from a Muse headset
struct EEGReading {
    var alpha: Double
    var beta: Double
    var gamma: Double
    var theta: Double
    var delta: Double
    
    // Computed property for beta-gamma chaos metric
    var betaGammaChaos: Double {
        return (beta + gamma) / 2.0
    }
}

/// Represents Heart Rate Variability metrics
struct HRVMetrics {
    var sdnn: Double  // Standard deviation of NN intervals
    var rmssd: Double // Root mean square of successive differences
    var lf: Double    // Low frequency power
    var hf: Double    // High frequency power
    
    // Computed properties
    var entropy: Double {
        // A simple entropy measure based on HRV
        return 1.0 - (rmssd / sdnn)
    }
    
    var coherence: Double {
        // LF/HF ratio, normalized to 0-1 range
        let ratio = lf / max(0.1, hf)  // Avoid division by zero
        return min(1.0, ratio / 4.0)    // Normalize (assuming ratio typically 0-4)
    }
}

/// Represents voice feature analysis
struct VoiceFeatures {
    var jitter: Double       // Frequency perturbation
    var shimmer: Double      // Amplitude perturbation
    var hnr: Double         // Harmonics-to-noise ratio
    var pauseCount: Int     // Number of speech pauses
    var speakingRate: Double // Words per minute
    var facialConsistencyScore: Double  // 0-1, higher means more consistent facial expressions
    
    // Computed property for pause disorder metric
    var pauseDisorder: Double {
        // Higher pause count and lower speaking rate indicate more disorganized speech
        let normalizedPauses = Double(min(pauseCount, 10)) / 10.0  // Cap at 10 pauses
        let normalizedRate = min(speakingRate / 200.0, 1.0)        // Normalize to 200 wpm max
        return (normalizedPauses + (1.0 - normalizedRate)) / 2.0   // Average of both metrics
    }
}
