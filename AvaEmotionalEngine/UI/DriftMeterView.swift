import SwiftUI

struct DriftMeterView: View {
    var drift: Double // 0.0 (stable) to 1.0 (high drift)

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
            Capsule()
                .fill(drift < 0.33 ? Color.green : (drift < 0.66 ? Color.yellow : Color.red))
                .frame(width: CGFloat(drift) * 200, height: 16)
            Text("Drift: \(String(format: "%.2f", drift))")
                .font(.caption)
                .foregroundColor(.primary)
                .padding(.leading, 8)
        }
        .frame(width: 200)
    }
}
