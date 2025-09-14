import Foundation

private let epsilon = 1e-9

class KXRPEquationBank {
    // Computes individual KXRP metric by index (1-50)
    func computeKXRP(index: Int, eeg: EEGReading, hrv: HRVMetrics, voice: VoiceFeatures, entropy: Double,
                     psi: Double, psiPrev: Double, psiPositive: Double = 0.0, phiSecDeriv: Double = 0.0) -> Double {
        switch index {
        case 1:  // Calmness Index: (alpha + theta) / (beta + gamma)
            return (eeg.alpha + eeg.theta) / (eeg.beta + eeg.gamma + epsilon)
        case 2:  // Attention Stability: beta / (theta + delta)
            return eeg.beta / (eeg.theta + eeg.delta + epsilon)
        case 3:  // Emotional Drift Velocity: |dΨ/dt| approx = |psi - psiPrev|
            return abs(psi - psiPrev)
        case 4:  // Entropy-Coherence Ratio: coherence / entropy
            return hrv.coherence / (entropy + epsilon)
        case 5:  // Gamma Arousal Ratio: gamma / (alpha + theta)
            return eeg.gamma / (eeg.alpha + eeg.theta + epsilon)
        case 6:  // Flow Alignment Score: (alpha * beta) / (delta + drift)
            return (eeg.alpha * eeg.beta) / (eeg.delta + abs(psi - psiPrev) + epsilon)
        case 7:  // Mind-Body Synchrony: HRV * coherence / (1 + entropy)
            return hrv.rmssd * hrv.coherence / (1 + entropy)
        case 8:  // Suppression Load: |psi| / (gamma + HRV)
            return abs(psi) / (eeg.gamma + hrv.rmssd + epsilon)
        case 9:  // Internal Conflict: |Ψvalence – Ψtone| approx = |psi - facialConsistencyScore|
            return abs(psi - voice.facialConsistencyScore)
        case 10: // Predictive Collapse Risk: d²Φ/dt² + dHRV/dt (using phiSecDeriv + approximate hrv delta)
            let dHRV = hrv.rmssd - hrv.sdnn // approximate derivative
            return phiSecDeriv + dHRV
        case 11: // Emotional Transparency Ratio: psi / (voice tone + facial expression)
            return psi / (voice.hnr + voice.facialConsistencyScore + epsilon)
        case 12: // Presence Coherence Index: (coherence * alpha) / (entropy + theta)
            return hrv.coherence * eeg.alpha / (entropy + eeg.theta + epsilon)
        case 13: // Reflective Depth Index: (theta * alpha) / (gamma + drift)
            return (eeg.theta * eeg.alpha) / (eeg.gamma + abs(psi - psiPrev) + epsilon)
        case 14: // Social Resonance Index: (psi * voice tone * coherence) / (1 + entropy)
            return psi * voice.hnr * hrv.coherence / (1 + entropy)
        case 15: // Fatigue Detection: (delta + theta) / (beta + gamma)
            return (eeg.delta + eeg.theta) / (eeg.beta + eeg.gamma + epsilon)
        case 16: // Anticipatory Stress Load: approximate sum of dy/dt and dBeta/dt replaced by gamma + beta
            return eeg.gamma + eeg.beta
        case 17: // Emotional Coherence Delta: |psi - psiPrev|
            return abs(psi - psiPrev)
        case 18: // Emotional Reciprocity Index: psi*psiR / (1 + |psi - psiR|), using facialConsistencyScore as psiR
            return psi * voice.facialConsistencyScore / (1 + abs(psi - voice.facialConsistencyScore))
        case 19: // Sensory Overload Indicator: (gamma + beta) / (HRV + coherence)
            return (eeg.gamma + eeg.beta) / (hrv.rmssd + hrv.coherence + epsilon)
        case 20: // Stillness Quotient: alpha / (drift + gamma)
            return eeg.alpha / (abs(psi - psiPrev) + eeg.gamma + epsilon)
        case 21: // Suppressed Empathy Index: |psi - psiR| / (voice tone + facial expression)
            return abs(psi - voice.facialConsistencyScore) / (voice.hnr + epsilon)
        case 22: // Restoration Potential: HRV * coherence / (fatigue + entropy), fatigue approximated by KXRP_15
            let fatigue = (eeg.delta + eeg.theta) / (eeg.beta + eeg.gamma + epsilon)
            return hrv.rmssd * hrv.coherence / (fatigue + entropy + epsilon)
        case 23: // Cognitive Load Index: (beta + gamma) / (alpha + theta)
            return (eeg.beta + eeg.gamma) / (eeg.alpha + eeg.theta + epsilon)
        case 24: // Empathic Safety Ratio: (coherence * voice tone) / (|psi| + entropy)
            return hrv.coherence * voice.hnr / (abs(psi) + entropy + epsilon)
        case 25: // Emotional Echo Stability: psi * psiPrev / (1 + |psi - psiPrev|)
            return psi * psiPrev / (1 + abs(psi - psiPrev))
        case 26: // Co-regulation Efficiency (placeholder): approximated by psi (requires time-series)
            return psi
        case 27: // Relational Drift Index: |psi - psiP| approx using facial consistency score as psiP
            return abs(psi - voice.facialConsistencyScore)
        case 28: // Emotional Gravity Vector: ∇Ψ(t), approximate as difference |psi - psiPrev|
            return abs(psi - psiPrev)
        case 29: // Emotional Divergence Rate: d/dt(ΨH - ΨR), approx |psi - facialConsistencyScore|
            return abs(psi - voice.facialConsistencyScore)
        case 30: // Resilience Quotient: HRV * alpha / (delta + entropy)
            return hrv.rmssd * eeg.alpha / (eeg.delta + entropy + epsilon)
        case 31: // Emotional Loop Closure: Ψ(t)·(1 - |Ψ(t) – Ψ(t-τ)|) / (|Ψ(t)| + |Ψ(t-τ)| + ε)
            return psi * (1 - abs(psi - psiPrev)) / (abs(psi) + abs(psiPrev) + epsilon)
        case 32: // Trust Stability Index: Ψpositive * coherence / (1 + KXRP29), approximate denominator = 1 + KXRP29 as zero
            return psiPositive * hrv.coherence / 1.0
        case 33: // Cognitive-Affective Load Balance: (gamma + beta) / (psi + entropy)
            return (eeg.gamma + eeg.beta) / (psi + entropy + epsilon)
        case 34: // Inner Voice Synchrony: (psi * toneInner) / (emotionalTransparency + 1), approximating toneInner as voice.hnr
            let emotionalTransparency = computeKXRP(index: 11, eeg: eeg, hrv: hrv, voice: voice, entropy: entropy, psi: psi, psiPrev: psiPrev)
            return (psi * voice.hnr) / (emotionalTransparency + 1)
        case 35: // Vulnerability Openness Index: psi / (suppression + 1), estimate suppression from KXRP_8
            let suppression = computeKXRP(index: 8, eeg: eeg, hrv: hrv, voice: voice, entropy: entropy, psi: psi, psiPrev: psiPrev)
            return psi / (suppression + 1)
        case 36: // Recovery Trajectory Gradient: d/dt KXRP22, placeholder as difference
            let kxrp22Now = computeKXRP(index: 22, eeg: eeg, hrv: hrv, voice: voice, entropy: entropy, psi: psi, psiPrev: psiPrev)
            let kxrp22Prev = kxrp22Now // in real system, use time lagged value
            return kxrp22Now - kxrp22Prev
        case 37: // Compassion Activation Index: (Ψempathy * Ψconcern) / (1 + Emotional Fatigue), placeholders with psi & psiPrev
            return (psi * psiPrev) / (1 + entropy)
        case 38: // Adaptive Emotional Range: max(psi) - min(psi), approximated as abs(psi - psiPrev)
            return abs(psi - psiPrev)
        case 39: // Neural Entropy Index: entropy
            return entropy
        case 40: // Empathic Field Resonance: (ΨH * Ψp * coherence) / (1 + |ΨH - Ψp|), using psi and facialConsistencyScore for ΨH and Ψp
            let diff = abs(psi - voice.facialConsistencyScore)
            return (psi * voice.facialConsistencyScore * hrv.coherence) / (1 + diff)
        case 41: // Moment of Meaning Index: (Ψ² * alpha) / (entropy + 1)
            return (psi * psi * eeg.alpha) / (entropy + 1)
        case 42: // Trust Formation Momentum: d/dt KXRP32, placeholder zero
            return 0 // needs time series data for rate of change
        case 43: // Emotional Compression Ratio: sum of |psi| / (verbal + facial expression), approximated as psi / (hrv + facialConsistency)
            return abs(psi) / (voice.hnr + voice.facialConsistencyScore + epsilon)
        case 44: // Cognitive-Emotional Alignment Score: (beta + alpha) / (|psi - phi| + 1), phi unknown - approximated by psiPrev
            return (eeg.beta + eeg.alpha) / (abs(psi - psiPrev) + 1)
        case 45: // Emotional Anticipation Signal: second derivative of psi, approximated as |psi - 2*psiPrev + psiPrev| (simplified)
            return abs(psi - 2 * psiPrev + psiPrev) // Simplified second difference
        case 46: // Grounding Potential Index: (alpha * HRV) / (gamma + entropy)
            return (eeg.alpha * hrv.rmssd) / (eeg.gamma + entropy + epsilon)
        case 47: // Emotional Continuity Ratio: (psi * psiPrev) / (1 + |psi - psiPrev|)
            return (psi * psiPrev) / (1 + abs(psi - psiPrev))
        case 48: // Self-Perception Alignment: (psi * selfNarrative) / (|psi - toneInner| + 1), approximating selfNarrative as psiPrev and toneInner as voice.hnr
            return (psi * psiPrev) / (abs(psi - voice.hnr) + 1)
        case 49: // Synthetic Presence Quotient: (coherence * psi * alpha) / (1 + entropy + |dpsi|)
            return hrv.coherence * psi * eeg.alpha / (1 + entropy + abs(psi - psiPrev))
        case 50:
            // Build a single-epoch time-series for KXRP_1..KXRP_49 and compute omega via the integrator.
            var kxrpValues: [[Double]] = []
            for i in 1...49 {
                // compute each metric for the current epoch (avoid calling 50)
                let val = self.computeKXRP(index: i, eeg: eeg, hrv: hrv, voice: voice,
                                          entropy: entropy, psi: psi, psiPrev: psiPrev,
                                          psiPositive: psiPositive, phiSecDeriv: phiSecDeriv)
                kxrpValues.append([val])
            }
            let weights: [Double] = [1.0] // single sample weight
            let integrator = KXRPOmegaIntegrator()
            return integrator.calculateOmegaIndex(kxrpValues: kxrpValues, weights: weights)
        default:
            return 0.0
        }
    }
}

class KXRPOmegaIntegrator {
    // epsilon to avoid division by zero
    private let epsilon = 1e-9

    // Computes the Omega Integration Index (KXRP_50)
    // Parameters:
    // - kxrpValues: Array of arrays, each inner array contains the time series (samples) of a single KXRP metric (1 to 49).
    //   So kxrpValues[0] = time series of KXRP_1, ..., kxrpValues[48] = time series of KXRP_49
    // - weights: Array of weights w(τ) corresponding to each time index for integration
    // Assumes all kxrpValues have the same time length, and weights length matches time length
    func calculateOmegaIndex(kxrpValues: [[Double]], weights: [Double]) -> Double {
        let numberOfMetrics = kxrpValues.count  // Should be 49
        guard numberOfMetrics == 49 else {
            fatalError("Expected 49 metrics for KXRP_1 to KXRP_49 integration.")
        }
        let timeLength = weights.count
        // Verify all metric time series have the same length as weights
        for metricSeries in kxrpValues {
            guard metricSeries.count == timeLength else {
                fatalError("Time series length mismatch between KXRP metrics and weights.")
            }
        }

        // Weighted integral approximation using discrete sum:
        // Omega = ∫(sum_kxrp_i(τ) * w(τ)) dτ ≈ Στ [ (Σi kxrp_i(τ)) * w(τ) ] * Δt
        // Assuming Δt = 1 for simplicity; can be scaled if needed
        var omegaSum = 0.0

        for t in 0..<timeLength {
            var sumAtT = 0.0
            for metricIndex in 0..<numberOfMetrics {
                sumAtT += kxrpValues[metricIndex][t]
            }
            omegaSum += sumAtT * weights[t]
        }

        return omegaSum
    }
}


