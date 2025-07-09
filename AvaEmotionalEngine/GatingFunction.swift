import Foundation

class GatingFunction {
    func shouldRespond(psi: Float, entropy: Float, coherence: Float, integrity: Float) -> Bool {
        return psi > 0.6 && entropy < 0.3 && coherence > 0.5 && integrity > 0.6
    }
}
