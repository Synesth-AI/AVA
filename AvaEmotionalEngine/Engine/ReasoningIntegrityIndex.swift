class ReasoningIntegrityIndex {
    // Tracks symbolic trust over time
    private var integrityHistory: [Double] = []

    func updateIntegrity(currentOmega: Double) {
        integrityHistory.append(currentOmega)
        if integrityHistory.count > 100 {
            integrityHistory.removeFirst()
        }
    }

    func averageIntegrity() -> Double {
        guard !integrityHistory.isEmpty else { return 1.0 }
        return integrityHistory.reduce(0, +) / Double(integrityHistory.count)
    }
}
