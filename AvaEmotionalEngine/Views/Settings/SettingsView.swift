import SwiftUI

struct SettingsView: View {
    @State private var eegEnabled = true
    @State private var hrvEnabled = true
    @State private var healthKitEnabled = false
    @State private var homeKitEnabled = false
    @State private var notificationsEnabled = false
    @State private var microphoneEnabled = false
    @StateObject private var connectedDevicesManager = ConnectedDevicesManager()
    @State private var isConnecting = false
    @State private var connectingDevice: Device?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.04), Color.purple.opacity(0.04)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Main Title
                VStack(alignment: .leading, spacing: 2) {
                    Text("Settings & Privacy")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Text("Manage your data & devices")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Data Collection Card
                        SettingsCard(
                            icon: "shield.fill",
                            iconColor: .blue,
                            title: "Data Collection"
                        ) {
                            SettingsToggleRow(label: "EEG Brain Activity", isOn: $eegEnabled)
                            SettingsToggleRow(label: "Heart Rate Variability", isOn: $hrvEnabled)
                        }

                        // Permissions Card
                        SettingsCard(
                            icon: "shield.lefthalf.fill",
                            iconColor: .orange,
                            title: "Permissions"
                        ) {
                            SettingsToggleRow(label: "HealthKit Access", isOn: $healthKitEnabled)
                            SettingsToggleRow(label: "HomeKit Access", isOn: $homeKitEnabled)
                            SettingsToggleRow(label: "Smart Notifications", isOn: $notificationsEnabled)
                            SettingsToggleRow(label: "Microphone Access", isOn: $microphoneEnabled)
                        }

                        // Data Management Card
                        SettingsCard(
                            icon: "externaldrive.fill",
                            iconColor: .pink,
                            title: "Data Management"
                        ) {
                            HStack {
                                Text("Export My Data")
                                    .font(.system(size: 17, weight: .regular))
                                Spacer()
                                Button(action: {
                                    // Export action
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.pink.opacity(0.1))
                                    .foregroundColor(.pink)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.vertical, 2)
                        }

                        // Connected Devices Card
                        SettingsCard(
                            icon: "link.circle.fill",
                            iconColor: .green,
                            title: "Connected Devices"
                        ) {
                            ForEach(connectedDevicesManager.devices) { device in
                                HStack {
                                    Text(device.name)
                                        .font(.system(size: 17))
                                    Spacer()
                                    Button(action: {
                                        if device.isConnected {
                                            connectedDevicesManager.updateConnection(for: device, isConnected: false)
                                        } else {
                                            connectingDevice = device
                                            isConnecting = true
                                            // Simulate connection delay
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                connectedDevicesManager.updateConnection(for: device, isConnected: true)
                                                isConnecting = false
                                            }
                                        }
                                    }) {
                                        Text(device.isConnected ? "Disconnect" : "Connect")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(device.isConnected ? .gray : .blue)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 6)
                                            .background((device.isConnected ? Color.gray : Color.blue).opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                    .disabled(isConnecting && connectingDevice == device)
                                    Button(action: {
                                        connectedDevicesManager.removeDevice(device)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 4)
                                    }
                                }
                            }
                        }

                        // Privacy & Security Card
                        SettingsCard(
                            icon: "eye.fill",
                            iconColor: .purple,
                            title: "Privacy & Security"
                        ) {
                            Text("All brain data is processed locally on your device. Personal data is encrypted and never shared. You can export or delete your data at any time.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .padding(.bottom, 12)
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    Text("Privacy Policy")
                                        .font(.system(size: 15, weight: .semibold))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .clipShape(Capsule())
                                }
                                Button(action: {}) {
                                    Text("Terms of Service")
                                        .font(.system(size: 15, weight: .semibold))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }

                // Bottom Navigation Bar
                Divider()
                HStack {
                    NavBarItem(icon: "house", label: "Home", selected: true)
                    NavBarItem(icon: "timer", label: "Sessions")
                    NavBarItem(icon: "book.closed", label: "Journal")
                    NavBarItem(icon: "arrow.2.circlepath", label: "Sync")
                }
                .frame(height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: -2)
                .padding(.horizontal, 0)
                .padding(.bottom, 0)
            }
        }
        .font(.custom("SF Pro", size: 17))
    }
}

// MARK: - Components

struct SettingsCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: Content

    init(icon: String, iconColor: Color, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.bottom, 2)
            VStack(spacing: 10) {
                content
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct SettingsToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    var disabled: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 17))
                .foregroundColor(disabled ? .gray : .black)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .disabled(disabled)
                .toggleStyle(SwitchToggleStyle(tint: disabled ? Color.gray.opacity(0.4) : Color.green))
        }
        .opacity(disabled ? 0.5 : 1.0)
    }
}

struct SettingsDeviceRow: View {
    let deviceName: String
    let isConnected: Bool
    let connectColor: Color

    var body: some View {
        HStack {
            Text(deviceName)
                .font(.system(size: 17))
            Spacer()
            Button(action: {}) {
                Text(isConnected ? "Disconnect" : "Connect")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(connectColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(connectColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            Image(systemName: "trash")
                .foregroundColor(.gray)
                .padding(.leading, 4)
        }
    }
}

struct NavBarItem: View {
    let icon: String
    let label: String
    var selected: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(selected ? .blue : .gray)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(selected ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
