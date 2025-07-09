import SwiftUI

struct EmotionalFaceView: View {
    var psi: Double
    var entropy: Double
    var coherence: Double

    var body: some View {
        let mood = moodForState(psi: psi, entropy: entropy, coherence: coherence)
        ZStack {
            Circle()
                .fill(mood.background)
                .frame(width: 100, height: 100)
            Image(systemName: mood.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
        }
        .shadow(radius: 4)
    }

    func moodForState(psi: Double, entropy: Double, coherence: Double) -> (icon: String, background: Color) {
        if psi > 0.7 && coherence > 0.7 {
            return ("face.smiling", Color.green)
        } else if entropy > 0.7 {
            return ("face.dashed", Color.orange)
        } else if psi < 0.4 {
            return ("face.sad.tear", Color.blue)
        } else {
            return ("face.neutral", Color.gray)
        }
    }
}
