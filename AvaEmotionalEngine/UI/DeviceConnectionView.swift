import SwiftUI

struct DeviceConnectionView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with greeting
            VStack(spacing: 16) {
                Text("Hi \(appState.userName)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                
                Text("Let's get you set up with your devices")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)
            .padding(.bottom, 40)
            
            // Device connection cards
            VStack(spacing: 20) {
                // Muse Headband Card
                DeviceCard(
                    title: "Muse Headband",
                    description: "Connect your Muse headband to track your brain activity and heart rate variability (HRV).",
                    buttonTitle: "Connect",
                    buttonAction: {
                        // TODO: Implement Muse connection
                    },
                    iconName: "brain.head.profile"
                )
                
                // Apple Watch Card
                DeviceCard(
                    title: "Apple Watch",
                    description: "Connect your Apple Watch to track your heart rate and other health metrics.",
                    buttonTitle: "Connect",
                    buttonAction: {
                        // TODO: Implement Apple Watch connection
                    },
                    iconName: "applewatch"
                )
                
                // Skip for now button
                Button(action: {
                    withAnimation {
                        appState.hasCompletedDeviceSetup = true
                    }
                }) {
                    Text("I'll do this later")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#2E69C3"))
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct DeviceCard: View {
    let title: String
    let description: String
    let buttonTitle: String
    let buttonAction: () -> Void
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#2E69C3"))
                    .frame(width: 48, height: 48)
                    .background(Color(hex: "#2E69C3").opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#2E69C3"))
                        .cornerRadius(16)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct DeviceConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceConnectionView()
            .environmentObject(AppState())
    }
}
