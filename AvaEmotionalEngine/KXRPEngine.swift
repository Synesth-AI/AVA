import Foundation

class KXRPEngine {
    func computeMetrics(from bands: [String: Float]) -> (psi: Float, entropy: Float, coherence: Float, integrity: Float) {
        let psi = bands["alpha"] ?? 0.0
        let entropy = (bands["beta"] ?? 0.0) + (bands["gamma"] ?? 0.0)
        let coherence = max(0.0, 1.0 - entropy)
        let integrity = (psi + coherence) / 2.0
        return (psi, entropy, coherence, integrity)
    }
}
