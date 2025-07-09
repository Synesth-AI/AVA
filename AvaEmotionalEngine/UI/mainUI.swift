import SwiftUI

struct MainUI: View {
    @State private var psi: Double = 0.0
    @State private var entropy: Double = 0.0
    @State private var coherence: Double = 0.0
    @State private var omega: Double = 0.0
    @State private var drift: Double = 0.0
    @State private var isGuardianMode: Bool = false
    
    struct MainUI_Previews: PreviewProvider {
        static var previews: some View {
            MainUI()
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("AVA Emotional Mirror")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                EntropyRingView(entropy: entropy, coherence: coherence)
                    .frame(width: 180, height: 180)
                DriftMeterView(drift: drift)
                    .frame(height: 30)
                EmotionalFaceView(psi: psi, entropy: entropy, coherence: coherence)
                    .frame(width: 100, height: 100)
                Ω_CoherenceSymbol(omega: omega)
                    .frame(width: 60, height: 60)
                Spacer()
                Button(isGuardianMode ? "Exit Guardian Mode" : "Enter Guardian Mode") {
                    isGuardianMode.toggle()
                }
                .padding()
            }
            .blur(radius: isGuardianMode ? 8 : 0)
            if isGuardianMode {
                GuardianOverlayView()
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
