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
    private let interpreter = KXRPInterpreter()
    private let whisper = WhisperTrigger()
    
    // Timer for periodic updates
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var metrics: (
        psi: Float,
        entropy: Float,
        coherence: Float,
        integrity: Float,
        kxrpScores: [Float],
        ksxDelta: Float,
        psiOmegaLock: Bool,
        symbolicClassifications: [String],
        forecastScore: Float,
        mesqi: Float
    ) = (
        0, 0, 0, 0,
        Array(repeating: 0, count: 50),
        0, false, [], 0, 0
    )
    @State private var lastMessage: String = ""
    @State private var gatingEnabled: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                psi: metrics.psi,
                entropy: metrics.entropy,
                coherence: metrics.coherence,
                integrity: metrics.integrity,
                lastMessage: lastMessage,
                kxrpScores: metrics.kxrpScores,
                ksxDelta: metrics.ksxDelta,
                psiOmegaLock: metrics.psiOmegaLock,
                symbolicClassifications: metrics.symbolicClassifications,
                forecastScore: metrics.forecastScore,
                mesqi: metrics.mesqi,
                isGatingEnabled: $gatingEnabled
            )
            .onReceive(timer) { _ in
                updateMetrics()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Test AVA Speak") {
                        // Use current emulated metrics from state
                        let kxrpDict = Dictionary(uniqueKeysWithValues: metrics.kxrpScores.enumerated().map { (i, v) in (i+1, Double(v)) })
                        ava.respondBasedOnMetrics(
                            psi: Double(metrics.psi),
                            entropy: Double(metrics.entropy),
                            coherence: Double(metrics.coherence),
                            integrity: Double(metrics.integrity),
                            kxrpValues: kxrpDict,
                            gating: gatingEnabled
                        )
                    }
                }
            }
        }
    }
    
    private func updateMetrics() {
        let bands = eeg.getBandPowers()
        let hrvMetrics = hrvEmulator.getMetrics()
        let voiceFeatures = voiceExtractor.getFeatures()
        let newMetrics = engine.computeMetrics(eeg: bands, hrv: hrvMetrics, voice: voiceFeatures)
        // Determine if AVA should respond, respecting the gating switch
        let shouldSpeak = gatingEnabled && gate.shouldRespond(
            psi: newMetrics.psi,
            entropy: newMetrics.entropy,
            coherence: newMetrics.coherence,
            integrity: newMetrics.integrity
        )
        
        // Compute all 50 KXRP scores
        let kxrpScores = (1...50).map { idx in
            engine.computeMetrics(eeg: bands, hrv: hrvMetrics, voice: voiceFeatures, index: idx).psi
        }
        // Interpret symbolic results
        let interpResult = interpreter.interpret(eegBands: bands, hrv: hrvMetrics, voice: voiceFeatures)
        let suppressionHint = whisper.shouldSuppress(interpResult.symbolicClassifications)
            ? whisper.suppressionHint() : nil
        // Update metrics for the UI, including interpreter outputs
        metrics = (
            newMetrics.psi,
            newMetrics.entropy,
            newMetrics.coherence,
            newMetrics.integrity,
            kxrpScores,
            Float(interpResult.ksxDelta),
            interpResult.psiOmegaLock,
            interpResult.symbolicClassifications,
            Float(interpResult.forecastScore),
            Float(interpResult.mesqi)
        )

        // Automatically trigger AVA to speak if the response message changes
        let kxrpDict = Dictionary(uniqueKeysWithValues: kxrpScores.enumerated().map { (i, v) in (i+1, Double(v)) })
        let newMessage = ava.generateMessage(
            psi: Double(newMetrics.psi),
            entropy: Double(newMetrics.entropy),
            coherence: Double(newMetrics.coherence),
            integrity: Double(newMetrics.integrity),
            kxrpValues: kxrpDict
        )
        if newMessage != lastMessage {
            ava.respondBasedOnMetrics(
                psi: Double(newMetrics.psi),
                entropy: Double(newMetrics.entropy),
                coherence: Double(newMetrics.coherence),
                integrity: Double(newMetrics.integrity),
                kxrpValues: kxrpDict,
                gating: gatingEnabled
            )
            lastMessage = newMessage
        }

        // Log to console
        print("Ψ: \(newMetrics.psi), S: \(newMetrics.entropy), C: \(newMetrics.coherence), Ω: \(newMetrics.integrity), G: \(shouldSpeak)")
    }
}
