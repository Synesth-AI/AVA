import SwiftUI

struct Ω_CoherenceSymbol: View {
    var omega: Double // 0.0 to 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.purple.opacity(0.3), lineWidth: 6)
            Text("Ω")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(omega > 0.7 ? .purple : .gray)
                .shadow(radius: omega > 0.7 ? 8 : 2)
            if omega > 0.9 {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .offset(x: 30, y: -30)
            }
        }
        .frame(width: 60, height: 60)
        .accessibilityLabel("Coherence Symbol Omega")
    }
}
