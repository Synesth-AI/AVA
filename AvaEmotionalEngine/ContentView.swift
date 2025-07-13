import SwiftUI

struct ContentView: View {
    let psi: Float
    let entropy: Float
    let coherence: Float
    let integrity: Float
    let lastMessage: String
    
    // Computed property to determine if gating is active
    private var gating: Bool {
        // Gating is considered active when we have a last message
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
        lastMessage: "I am AVA. Emotional field is stable."
    )
}
