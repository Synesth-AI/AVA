import SwiftUI

struct SettingsView: View {
    @State private var eegEnabled = true
    @State private var hrvEnabled = true
    @State private var healthKitEnabled = false
    @State private var homeKitEnabled = false
    @State private var notificationsEnabled = false
    @State private var microphoneEnabled = false
    @StateObject private var connectedDevicesManager = ConnectedDevicesManager()
    @StateObject private var museManager = MuseManager.shared
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
                            // Decide which UI to show based on connection
                            if museManager.connectionState.isConnected {
                                // Connected panel (clean, minimal)
                                let name = museManager.connectionState.deviceName
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "headphones")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.green)
                                            .padding(10)
                                            .background(Color.green.opacity(0.12))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(name.isEmpty ? "Muse Device" : name)
                                                .font(.system(size: 17, weight: .semibold))
                                            HStack(spacing: 6) {
                                                Text("Connected")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(Color.green.opacity(0.12))
                                                    .clipShape(Capsule())
                                                if museManager.batteryLevel > 0 {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "battery.100")
                                                        Text("\(museManager.batteryLevel)%")
                                                    }
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    HStack {
                                        Button(action: { museManager.disconnect() }) {
                                            Text("Disconnect")
                                                .font(.system(size: 15, weight: .semibold))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.red.opacity(0.12))
                                                .foregroundColor(.red)
                                                .clipShape(Capsule())
                                        }
                                        Spacer()
                                    }
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                                )
                            } else {
                                // Not connected: scan & list
                                HStack {
                                    Button(action: { museManager.startScanning() }) {
                                        HStack(spacing: 8) {
                                            if museManager.isScanning {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                                    .scaleEffect(0.8)
                                            } else {
                                                Image(systemName: "arrow.clockwise")
                                            }
                                            Text(museManager.isScanning ? "Scanning…" : "Scan for Devices")
                                        }
                                        .padding(.horizontal, 12)
                                        .background(Color.green.opacity(0.12))
                                        .foregroundColor(.green)
                                        .clipShape(Capsule())
                                    }
                                    Spacer()
                                    switch museManager.connectionState {
                                    case .connecting(let name):
                                        Text("Connecting to \(name)…").font(.caption).foregroundColor(.gray)
                                    case .failed(_, let error):
                                        Text(error).font(.caption).foregroundColor(.orange)
                                    default:
                                        EmptyView()
                                    }
                                }
                                .padding(.bottom, 4)
                                if museManager.devices.isEmpty {
                                    HStack {
                                        Image(systemName: "antenna.radiowaves.left.and.right")
                                            .foregroundColor(.gray)
                                        Text("No devices found. Ensure Bluetooth is ON and tap 'Scan for Devices'.")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    ForEach(museManager.devices.sorted { $0.name < $1.name }) { device in
                                        HStack {
                                            Text(device.name)
                                                .font(.system(size: 17))
                                            Spacer()
                                            let isConnectingToThis = (isConnecting && connectingDevice == device)
                                            Button(action: {
                                                connectingDevice = device
                                                isConnecting = true
                                                museManager.connect(to: device)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                    isConnecting = false
                                                }
                                            }) {
                                                Text(isConnectingToThis ? "Connecting…" : "Connect")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.blue)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 6)
                                                    .background(Color.blue.opacity(0.1))
                                                    .clipShape(Capsule())
                                            }
                                            .disabled(isConnectingToThis)
                                        }
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
        .onAppear {
            // Begin scanning automatically when the settings screen opens
            museManager.startScanning()
        }
        .onDisappear {
            museManager.stopScanning()
        }
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
