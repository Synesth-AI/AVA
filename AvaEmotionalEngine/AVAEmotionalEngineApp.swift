import SwiftUI
import Combine
import AVFoundation
import Speech
import UserNotifications
import UIKit


@main
struct AVAEmotionalEngineApp: App {
    // MARK: - Permission Handling
    private func requestPermissions() {
        // Request speech recognition permission
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("✅ Speech recognition authorized")
            case .denied, .restricted, .notDetermined:
                print("⚠️ Speech recognition not authorized")
            @unknown default:
                print("❓ Unknown speech recognition status")
            }
        }
        
        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("✅ Microphone access granted")
            } else {
                print("⚠️ Microphone access denied")
            }
        }
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("⚠️ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }
    
    // Initialize AVA with the AI generator
    @StateObject var appState = AppState()
    
    // Create instances of the core components
    let eeg = MuseEEGReceiver()
    let hrvEmulator = HRVEmulator()
    let voiceExtractor = VoiceFeatureExtractor()
    let engine = KXRPEngine()
    let gate = GatingFunction()
    let interpreter = KXRPInterpreter()
    let whisper = WhisperTrigger()
    let emotionInterpreter = EmotionalInterpreter()
    
    // Initialize AI components with API key from environment variables
    let aiGenerator = AIResponseGenerator(
        cloudAPIKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    )
    
    // Initialize AVA with the AI generator
    let ava: AVAResponder
    
    // Timer for periodic updates
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var metrics: (
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
    @State var lastMessage: String = ""
    @State var gatingEnabled: Bool = true
    
    init() {
        // Initialize AVA with the AI generator
        self.ava = AVAResponder(aiGenerator: aiGenerator)
        print("AVAEmotionalEngine: Initializing with AI generator")
        
        // Request all necessary permissions
        requestPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isSplashActive {
                    SplashScreenView {
                        appState.finishSplash()
                    }
                    .environmentObject(appState)
                } else if !appState.hasCompletedOnboarding {
                    OnboardingView()
                        .environmentObject(appState)
                } else if !appState.hasCompletedDeviceSetup {
                    DeviceConnectionView()
                        .environmentObject(appState)
                } else {
                    ContentView(
                        psi: metrics.psi,
                        entropy: metrics.entropy,
                        coherence: metrics.coherence,
                        integrity: metrics.integrity,
                        ksxDelta: metrics.ksxDelta,
                        psiOmegaLock: metrics.psiOmegaLock,
                        symbolicClassifications: metrics.symbolicClassifications,
                        forecastScore: metrics.forecastScore,
                        mesqi: metrics.mesqi,
                        gatingEnabled: $gatingEnabled,
                        lastMessage: lastMessage,
                        kxrpScores: metrics.kxrpScores
                    )
                        .environmentObject(appState)
                }
            }
            .onAppear {
                // Request necessary permissions when the app appears
                requestMicrophonePermission()
                requestSpeechRecognitionPermission()
                requestNotificationPermission()
            }
            .onDisappear(perform: stopUpdates)
            .onReceive(timer) { _ in
                // Run metrics update on a background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    self.updateMetrics()
                }
            }

        }
    }
    
    func startUpdates() {
        // Initialize any necessary components or start any timers
        print("Starting AVA updates...")
        // Initial metrics update
        updateMetrics()
    }
    
    func stopUpdates() {
        // Clean up any resources or stop any timers
        print("Stopping AVA updates...")
    }
    
    // MARK: - Permission Requests
    
    func requestMicrophonePermission() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category and mode
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // Request permission with a short delay to ensure the audio session is properly set up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                audioSession.requestRecordPermission { granted in
                    if granted {
                        print("✅ Microphone permission granted")
                    } else {
                        print("⚠️ Microphone permission denied")
                        // Show an alert to the user about enabling microphone access in Settings
                        DispatchQueue.main.async {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController {
                                let alert = UIAlertController(
                                    title: "Microphone Access Required",
                                    message: "This app needs access to the microphone to process voice input. Please enable it in Settings.",
                                    preferredStyle: .alert
                                )
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                })
                                rootViewController.present(alert, animated: true)
                            }
                        }
                    }
                }
            }
        } catch {
            print("❌ Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Speech recognition permission granted")
                case .denied, .restricted, .notDetermined:
                    print("⚠️ Speech recognition permission not granted")
                    // Show an alert to the user about enabling speech recognition
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        let alert = UIAlertController(
                            title: "Speech Recognition Required",
                            message: "This app needs speech recognition to understand voice commands. Please enable it in Settings.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        })
                        rootViewController.present(alert, animated: true)
                    }
                @unknown default:
                    print("❓ Unknown speech recognition permission status")
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied")
            }
        }
    }
        
    func updateMetrics() {
        let bands = eeg.getBandPowers()
        let hrvMetrics = hrvEmulator.getMetrics()
        let voiceFeatures = voiceExtractor.getFeatures()
        let newMetrics = engine.computeMetrics(eeg: bands, hrv: hrvMetrics, voice: voiceFeatures)
        
        // Ensure we're on the main thread for UI updates and AVA operations
        DispatchQueue.main.async {
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
        
        // Create EEGReading from bands
        let eegReading = EEGReading(
            alpha: bands.alpha,
            beta: bands.beta,
            gamma: bands.gamma,
            theta: bands.theta,
            delta: bands.delta
        )
        
        // Get the interpreter result
        let interpResult = interpreter.interpret(
            eegBands: eegReading,
            hrv: hrvMetrics,
            voice: voiceFeatures
        )
        
        // Get thought mirror result for symbolic memory
        let thoughtMirror = ThoughtMirror()
        // Convert EEGReading to array of doubles in the order expected by ThoughtMirror: [alpha, beta, gamma, theta, delta]
        let eegArray = [
            eegReading.alpha,
            eegReading.beta,
            eegReading.gamma,
            eegReading.theta,
            eegReading.delta
        ]
        let thoughtResult = thoughtMirror.decode(
            eeg: eegArray,
            hrv: hrvMetrics.rmssd
        )
        
        // Get symbolic memory if available
        let symbolicMemory = thoughtResult.classifiers.first.flatMap { Codex.get($0) } ?? ""
        let suppressionHint = interpResult.symbolicClassifications.first
        
        // Update metrics with interpreter results
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
        let interpResult2 = emotionInterpreter.interpret(
            entropy: Double(newMetrics.entropy),
            coherence: Double(newMetrics.coherence),
            integrity: Double(newMetrics.integrity)
        )
        let newMessage = interpResult2.phrase
        
        if newMessage != lastMessage {
            // --- Symbolic memory enhancement ---
            if thoughtResult.whisperDecision == .decode && !symbolicMemory.isEmpty {
                // Speak symbolic memory first, then AVA's normal message
                ava.speakRaw(message: symbolicMemory)
                ava.respondBasedOnMetrics(
                    psi: Double(newMetrics.psi),
                    entropy: Double(newMetrics.entropy),
                    coherence: Double(newMetrics.coherence),
                    integrity: Double(newMetrics.integrity),
                    kxrpValues: kxrpDict,
                    gating: gatingEnabled
                )
            } else if thoughtResult.whisperDecision == .deferUntilReady {
                // Suppress AVA speech, show suppression hint
                print("[Suppressed]: " + (suppressionHint ?? "Symbolic state: output deferred"))
            } else {
                // Default: AVA normal speech
                ava.respondBasedOnMetrics(
                    psi: Double(newMetrics.psi),
                    entropy: Double(newMetrics.entropy),
                    coherence: Double(newMetrics.coherence),
                    integrity: Double(newMetrics.integrity),
                    kxrpValues: kxrpDict,
                    gating: gatingEnabled
                )
            }
            lastMessage = newMessage
        }
        
            // Log to console
            print("Ψ: \(newMetrics.psi), S: \(newMetrics.entropy), C: \(newMetrics.coherence), Ω: \(newMetrics.integrity), G: \(shouldSpeak)")
        }
    }
}

