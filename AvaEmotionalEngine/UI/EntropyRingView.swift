import SwiftUI

struct EntropyRingView: View {
    var entropy: Double    // 0.0 (calm) to 1.0 (chaos)
    var coherence: Double  // 0.0 (low) to 1.0 (high)

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            Circle()
                .trim(from: 0, to: min(coherence, 1.0))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.green, Color.blue]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: min(entropy, 1.0))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.orange, Color.red]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack {
                Text("Entropy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f", entropy))
                    .font(.title2)
                    .bold()
                Text("Coherence")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f", coherence))
                    .font(.title3)
            }
        }
    }
}

struct MainUI_Previews: PreviewProvider {
    static var previews: some View {
        MainUI()
    }
}
