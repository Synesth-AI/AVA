import Foundation

struct KXRPEquation: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    
    // Computed property for backward compatibility
    var index: Int { id }
    
    // All KXRP equations with their proper names
    static let sampleEquations: [KXRPEquation] = [
        KXRPEquation(id: 1, name: "Calmness Index"),
        KXRPEquation(id: 2, name: "Attention Stability"),
        KXRPEquation(id: 3, name: "Emotional Drift Velocity"),
        KXRPEquation(id: 4, name: "Entropy-Coherence Ratio"),
        KXRPEquation(id: 5, name: "Gamma Arousal Ratio"),
        KXRPEquation(id: 6, name: "Flow Alignment Score"),
        KXRPEquation(id: 7, name: "Mind-Body Synchrony"),
        KXRPEquation(id: 8, name: "Suppression Load"),
        KXRPEquation(id: 9, name: "Internal Conflict"),
        KXRPEquation(id: 10, name: "Predictive Collapse Risk"),
        KXRPEquation(id: 11, name: "Emotional Transparency Ratio"),
        KXRPEquation(id: 12, name: "Presence Coherence Index"),
        KXRPEquation(id: 13, name: "Reflective Depth Index"),
        KXRPEquation(id: 14, name: "Social Resonance Index"),
        KXRPEquation(id: 15, name: "Fatigue Detection"),
        KXRPEquation(id: 16, name: "Anticipatory Stress Load"),
        KXRPEquation(id: 17, name: "Emotional Coherence Delta"),
        KXRPEquation(id: 18, name: "Emotional Reciprocity Index"),
        KXRPEquation(id: 19, name: "Sensory Overload Indicator"),
        KXRPEquation(id: 20, name: "Stillness Quotient"),
        KXRPEquation(id: 21, name: "Suppressed Empathy Index"),
        KXRPEquation(id: 22, name: "Restoration Potential"),
        KXRPEquation(id: 23, name: "Cognitive Load Index"),
        KXRPEquation(id: 24, name: "Empathic Safety Ratio"),
        KXRPEquation(id: 25, name: "Emotional Echo Stability"),
        KXRPEquation(id: 26, name: "Co-regulation Efficiency"),
        KXRPEquation(id: 27, name: "Relational Drift Index"),
        KXRPEquation(id: 28, name: "Emotional Gravity Vector"),
        KXRPEquation(id: 29, name: "Emotional Divergence Rate"),
        KXRPEquation(id: 30, name: "Resilience Quotient"),
        KXRPEquation(id: 31, name: "Emotional Loop Closure"),
        KXRPEquation(id: 32, name: "Trust Stability Index"),
        KXRPEquation(id: 33, name: "Cognitive-Affective Load Balance"),
        KXRPEquation(id: 34, name: "Inner Voice Synchrony"),
        KXRPEquation(id: 35, name: "Vulnerability Openness Index"),
        KXRPEquation(id: 36, name: "Recovery Trajectory Gradient"),
        KXRPEquation(id: 37, name: "Compassion Activation Index"),
        KXRPEquation(id: 38, name: "Adaptive Emotional Range"),
        KXRPEquation(id: 39, name: "Neural Entropy Index"),
        KXRPEquation(id: 40, name: "Empathic Field Resonance"),
        KXRPEquation(id: 41, name: "Moment of Meaning Index"),
        KXRPEquation(id: 42, name: "Trust Formation Momentum"),
        KXRPEquation(id: 43, name: "Emotional Compression Ratio"),
        KXRPEquation(id: 44, name: "Cognitive-Emotional Alignment"),
        KXRPEquation(id: 45, name: "Emotional Anticipation Signal"),
        KXRPEquation(id: 46, name: "Grounding Potential Index"),
        KXRPEquation(id: 47, name: "Emotional Continuity Ratio"),
        KXRPEquation(id: 48, name: "Self-Perception Alignment"),
        KXRPEquation(id: 49, name: "Synthetic Presence Quotient"),
        KXRPEquation(id: 50, name: "Omega Integration Index")
    ]
}
