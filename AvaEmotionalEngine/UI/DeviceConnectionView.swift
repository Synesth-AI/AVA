import SwiftUI

struct DeviceConnectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var isMuseConnected = false
    @State private var showDeviceSelection = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with greeting
            VStack(alignment: .leading, spacing: 16) {
                Text("Hi \(appState.userName)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                
                Text("Let's get you set up with your Muse headband")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 80) 
            .padding(.bottom, 40)
            
            // Main content with device card
            VStack(spacing: 0) {
                // Device connection card
                DeviceCard(
                    title: "Muse Headband",
                    description: "Connect your Muse headband to track your brain activity.",
                    buttonTitle: isMuseConnected ? "Connected" : "Connect",
                    buttonAction: {
                        if !isMuseConnected {
                            showDeviceSelection = true
                        }
                    },
                    iconName: "MuseIcon"
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Tips section
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("Make sure Bluetooth is enabled")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.7))
                            .multilineTextAlignment(.center)
                        Text("Keep your Muse headband close during pairing")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.7))
                            .multilineTextAlignment(.center)
                        Text("Ensure Muse headband is charged")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Skip for now button
                    Button(action: {
                        withAnimation {
                            appState.hasCompletedDeviceSetup = true
                        }
                    }) {
                        Text("I'll do this later")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#2E69C3"))
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 40) // Space between tips and continue button
                
                // Continue button
                Button(action: {
                    withAnimation {
                        // This will trigger the navigation to PermissionsView in the main app
                        appState.hasCompletedDeviceSetup = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(isMuseConnected ? "Continue" : "Connect Your Device")
                            .font(.headline)
                        
                        if isMuseConnected {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isMuseConnected ? Color(red: 0.18, green: 0.41, blue: 0.77) : Color.gray.opacity(0.5))
                    .cornerRadius(12)
                }
                .disabled(!isMuseConnected)
                .animation(.easeInOut, value: isMuseConnected)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        // Full screen overlay for device selection
        .overlay(
            Group {
                if showDeviceSelection {
                    ZStack {
                        // Blurred background
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    showDeviceSelection = false
                                }
                            }
                        
                        // Device selection view
                        DeviceSelectionView(isPresented: $showDeviceSelection) { selectedDevice in
                            // Handle device selection
                            withAnimation(.easeInOut) {
                                isMuseConnected = true
                                showDeviceSelection = false
                            }
                        }
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        )
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
            // Icon and text in a row
            HStack(alignment: .top, spacing: 12) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .cornerRadius(4)
                
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
            }
            
            // Connect button
            Button(action: buttonAction) {
                Text(buttonTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(buttonTitle == "Connected" ? Color(hex: "#2EC360") : Color(red: 0.18, green: 0.41, blue: 0.77))
                    .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }


struct DeviceConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceConnectionView()
            .environmentObject(AppState())
    }
}
