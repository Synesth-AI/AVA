class CDI_Brake {
    func shouldBrake(psi: Double, entropy: Double, coherence: Double) -> Bool {
        // Example: Brake if entropy is high and coherence drops
        return entropy > 0.6 && coherence < 0.4
    }
}
