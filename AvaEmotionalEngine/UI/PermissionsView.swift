import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject var appState: AppState
    @State private var microphoneEnabled = false
    @State private var speechRecognitionEnabled = false
    @State private var notificationsEnabled = false
    @State private var homeKitEnabled = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Let's get started!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("We need a few permissions to get AVA up to speed")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)  
            .padding(.bottom, 20)
            
            // Permissions List
            VStack(spacing: 24) {
                PermissionRow(
                    title: "Health Kit",
                    description: "To access your health data for better insights",
                    iconName: "health_icon",
                    isOn: $speechRecognitionEnabled
                )
                
                PermissionRow(
                    title: "HomeKit",
                    description: "To control your smart home devices",
                    iconName: "homekit_icon",
                    isOn: $homeKitEnabled
                )
                
                PermissionRow(
                    title: "Smart Notifications",
                    description: "To send you important updates and reminders",
                    iconName: "notification_icon",
                    isOn: $notificationsEnabled
                )
                
                PermissionRow(
                    title: "Microphone Access",
                    description: "To analyze your voice and detect emotional cues",
                    iconName: "microphone_icon",
                    isOn: $microphoneEnabled
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Spacer()
            
            // Continue Button
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation {
                        appState.hasCompletedPermissionsSetup = true
                        appState.hasCompletedOnboarding = true
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#2E69C3"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
}

struct PermissionRow: View {
    let title: String
    let description: String
    let iconName: String  // This will now be the name of the image asset
    @Binding var isOn: Bool
    
    // Constants for consistent sizing
    private let iconSize: CGFloat = 40
    private let toggleWidth: CGFloat = 50
    
    // Background color based on permission type
    private var iconBackgroundColor: Color {
        switch iconName {
        case "microphone_icon":
            return Color(hex: "#D3C3FF")  // Light purple for microphone
        case "health_icon":
            return Color(hex: "#FFD4D4")  // Light red for health
        case "notification_icon":
            return Color(hex: "#FFE3EB")  // Light pink for notifications
        case "homekit_icon":
            return Color(hex: "#FFE0C2")  // Light orange for HomeKit
        default:
            return Color(hex: "#2E69C3").opacity(0.1)  // Default color
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Icon container with fixed width
            HStack {
                Image(iconName)  // Using the custom image asset
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: iconSize, height: iconSize)
                    .background(iconBackgroundColor)
                    .cornerRadius(8)
                Spacer()
            }
            .frame(width: iconSize + 16) // Icon width + spacing
            
            // Text container that takes remaining space
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Toggle with fixed width to prevent movement
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "#2E69C3"))
                .frame(width: toggleWidth, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView()
            .environmentObject(AppState())
    }
}
