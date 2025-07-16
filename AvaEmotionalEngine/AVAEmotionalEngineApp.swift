import SwiftUI
import Combine

@main
struct AVAEmotionalEngineApp: App {
    // Create instances of the core components
    private let eeg = MuseEEGReceiver()
    private let hrvEmulator = HRVEmulator()
    private let voiceExtractor = VoiceFeatureExtractor()
    private let engine = KXRPEngine()
    private let gate = GatingFunction()
    private let ava = AVAResponder()
    
    // Timer for periodic updates
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var metrics: (psi: Float, entropy: Float, coherence: Float, integrity: Float, kxrpScores: [Float]) = (0, 0, 0, 0, Array(repeating: 0, count: 50))
    @State private var lastMessage: String = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                psi: metrics.psi,
                entropy: metrics.entropy,
                coherence: metrics.coherence,
                integrity: metrics.integrity,
                lastMessage: lastMessage,
                kxrpScores: metrics.kxrpScores
            )
            .onReceive(timer) { _ in
                updateMetrics()
            }
        }
    }
    
    private func updateMetrics() {
        let bands = eeg.getBandPowers()
        let hrvMetrics = hrvEmulator.getMetrics()
        let voiceFeatures = voiceExtractor.getFeatures()
        let newMetrics = engine.computeMetrics(eeg: bands, hrv: hrvMetrics, voice: voiceFeatures)
        let shouldSpeak = gate.shouldRespond(
            psi: newMetrics.psi,
            entropy: newMetrics.entropy,
            coherence: newMetrics.coherence,
            integrity: newMetrics.integrity
        )
        
        // Compute all 50 KXRP scores
        let kxrpScores = (1...50).map { idx in
            engine.computeMetrics(eeg: bands, hrv: hrvMetrics, voice: voiceFeatures, index: idx).psi
        }
        // Update metrics for the UI
        metrics = (newMetrics.psi, newMetrics.entropy, newMetrics.coherence, newMetrics.integrity, kxrpScores)
        
        // Handle AVA response
        if shouldSpeak {
            let message = "I am AVA. Emotional field is stable."
            ava.respondIfPermitted(true, message: message)
            lastMessage = message
        } else {
            lastMessage = ""
        }
        
        // Log to console
        print("Ψ: \(newMetrics.psi), S: \(newMetrics.entropy), C: \(newMetrics.coherence), Ω: \(newMetrics.integrity), G: \(shouldSpeak)")
    }
}
