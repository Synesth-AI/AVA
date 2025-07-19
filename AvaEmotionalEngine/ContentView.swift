import SwiftUI

struct ContentView: View {
    let psi: Float
    let entropy: Float
    let coherence: Float
    let integrity: Float
    let lastMessage: String
    let kxrpScores: [Float]?
    let ksxDelta: Float
    let psiOmegaLock: Bool
    let symbolicClassifications: [String]
    let forecastScore: Float
    let mesqi: Float

    @State private var showAllEquations = false

    // Computed property to determine if gating is active
    private var gating: Bool {
        return !lastMessage.isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("AVA Emotional Engine")
                .font(.largeTitle)
                .padding()

            // Metrics display
            VStack(spacing: 10) {
                MetricView(label: "Ψ(t):", value: psi)
                MetricView(label: "S(t):", value: entropy)
                MetricView(label: "C(t):", value: coherence)
                MetricView(label: "Ω(t):", value: integrity)

                Text("Gating: \(gating ? "ON" : "OFF")")
                    .foregroundColor(gating ? .green : .red)
                    .padding(.top, 10)

                if !lastMessage.isEmpty {
                    Text("Last Message:")
                        .font(.headline)
                        .padding(.top, 10)
                    Text(lastMessage)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                // Toggle and list for 50 equation scores
                if let kxrpScores = kxrpScores {
                    Toggle("Show All 50 Equation Scores", isOn: $showAllEquations)
                        .padding(.top, 10)
                    if showAllEquations {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(0..<kxrpScores.count, id: \.self) { i in
                                    HStack {
                                        Text("KXRP \(i+1):")
                                            .font(.caption)
                                            .frame(width: 70, alignment: .leading)
                                        Text(String(format: "%.4f", kxrpScores[i]))
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxHeight: 300)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Spacer()

            // Status indicator
            Text("Running...")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

// Helper view for consistent metric display
struct MetricView: View {
    let label: String
    let value: Float
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .frame(width: 60, alignment: .leading)
            
            ProgressView(value: Double(value), total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
            
            Text(String(format: "%.2f", value))
                .frame(width: 50, alignment: .trailing)
        }
    }
}

#Preview {
    ContentView(
        psi: 0.75,
        entropy: 0.45,
        coherence: 0.82,
        integrity: 0.67,
        lastMessage: "I am AVA. Emotional field is stable.",
        kxrpScores: Array(repeating: 0.1234, count: 50),
        ksxDelta: 0.05,
        psiOmegaLock: true,
        symbolicClassifications: ["Class A", "Class B"],
        forecastScore: 0.85,
        mesqi: 0.95
    )
}
