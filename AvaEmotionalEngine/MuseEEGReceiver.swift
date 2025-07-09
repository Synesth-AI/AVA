import Foundation

class MuseEEGReceiver {
    private var t: Float = 0.0

    func getBandPowers() -> [String: Float] {
        t += 0.1
        return [
            "alpha": 0.5 + 0.1 * sin(t),
            "beta": 0.2 + 0.05 * cos(t),
            "gamma": 0.1 + 0.02 * sin(2 * t),
            "theta": 0.15 + 0.03 * cos(t),
            "delta": 0.05 + 0.01 * sin(t)
        ]
    }
}
