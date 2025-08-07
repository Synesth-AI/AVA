import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var appState: AppState
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            // Gradient circles
            ZStack {
                // First gradient circle (pink)
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 337, height: 337)
                    .background(Color(red: 0.88, green: 0.44, blue: 0.56))
                    .cornerRadius(337)
                    .blur(radius: 50)
                    .offset(x: -111, y: 536)
                
                // Second gradient circle (blue)
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 337, height: 337)
                    .background(Color(red: 0.4, green: 0.76, blue: 0.86))
                    .cornerRadius(337)
                    .blur(radius: 50)
                    .offset(x: 226, y: 561)
            }
            
            VStack(spacing: 16) {
                // Logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                // App Name
                Text("AVA")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                
                // Tagline
                Text("Emotional Intelligence Engine")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.8))
            }
        }
        .onAppear {
            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        SplashScreenView {
            appState.finishSplash()
        }
        .environmentObject(appState)
    }
}
