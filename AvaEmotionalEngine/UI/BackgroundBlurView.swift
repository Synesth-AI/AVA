import SwiftUI

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct BackgroundBlurView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundBlurView()
            .ignoresSafeArea()
            .background(Color.black.opacity(0.3))
    }
}
