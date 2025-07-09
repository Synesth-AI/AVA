import SwiftUI

struct ContentView: View {
    @State private var psi: Float = 0.0
    @State private var entropy: Float = 0.0
    @State private var coherence: Float = 0.0
    @State private var integrity: Float = 0.0
    @State private var gating: Bool = false

    let engine = KXRPEngine()
    let gate = GatingFunction()
    let responder = AVAResponder()
    let eeg = MuseEEGReceiver()

    var body: some View {
        VStack(spacing: 20) {
            Text("AVA Emotional Engine").font(.largeTitle).padding()
            Text("Ψ(t): \(String(format: "%.2f", psi))")
            Text("S(t): \(String(format: "%.2f", entropy))")
            Text("C(t): \(String(format: "%.2f", coherence))")
            Text("Ω(t): \(String(format: "%.2f", integrity))")
            Text("Gating: \(gating ? "ON" : "OFF")")
                .foregroundColor(gating ? .green : .red)
            Spacer()
            Button("Run Engine Once") {
                let bands = eeg.getBandPowers()
                let metrics = engine.computeMetrics(from: bands)
                psi = metrics.psi
                entropy = metrics.entropy
                coherence = metrics.coherence
                integrity = metrics.integrity
                gating = gate.shouldRespond(
                    psi: psi,
                    entropy: entropy,
                    coherence: coherence,
                    integrity: integrity
                )
                responder.respondIfPermitted(gating, message: "Emotional field is stable.")
            }
            .padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
        }
        .padding()
    }
}
