import Foundation

let eeg = MuseEEGReceiver()
let engine = KXRPEngine()
let gate = GatingFunction()
let ava = AVAResponder()

Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    let bands = eeg.getBandPowers()
    let metrics = engine.computeMetrics(from: bands)
    let shouldSpeak = gate.shouldRespond(
        psi: metrics.psi,
        entropy: metrics.entropy,
        coherence: metrics.coherence,
        integrity: metrics.integrity
    )
    ava.respondIfPermitted(shouldSpeak, message: "I am AVA. Emotional field is stable.")
    print("Ψ: \(metrics.psi), S: \(metrics.entropy), C: \(metrics.coherence), Ω: \(metrics.integrity), G: \(shouldSpeak)")
}
RunLoop.main.run()
