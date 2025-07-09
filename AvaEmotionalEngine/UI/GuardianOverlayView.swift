import SwiftUI

struct GuardianOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "shield.lefthalf.filled")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.yellow)
                Text("Guardian Mode Active")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                Text("Calm protection is ON.\nCertain features are restricted for safety.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
            }
            .padding(.top, 120)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: true)
    }
}
