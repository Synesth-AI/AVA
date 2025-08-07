import SwiftUI

enum ConnectionState: Equatable {
    case disconnected
    case connecting(deviceName: String)
    case connected(deviceName: String)
    case failed(deviceName: String, error: String)
}

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let signalStrength: Int // 1-3 for signal strength indicators
    var isConnected: Bool = false
}

struct DeviceSelectionView: View {
    @Binding var isPresented: Bool
    @State private var devices: [Device] = [
        Device(name: "Muse S-1234", signalStrength: 3, isConnected: false),
        Device(name: "Muse S-5678", signalStrength: 2, isConnected: false),
        Device(name: "Muse 2-ABCD", signalStrength: 1, isConnected: false)
    ]
    @State private var isScanning = true
    @State private var selectedDevice: Device?
    @State private var connectionState: ConnectionState = .disconnected
    @State private var connectionError: String?
    
    var onDeviceSelected: ((Device) -> Void)?
    
    private func connectToDevice(_ device: Device) {
        // Simulate connection attempt (2 seconds)
        connectionState = .connecting(deviceName: device.name)
        
        // 20% chance of failure for demonstration
        let willFail = Int.random(in: 1...5) == 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if willFail {
                connectionState = .failed(deviceName: device.name, error: "Connection timed out")
                connectionError = "Could not connect to \(device.name). Please try again."
            } else {
                connectionState = .connected(deviceName: device.name)
                // Close the popup after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isPresented = false
                    onDeviceSelected?(device)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                switch connectionState {
                case .connecting(let deviceName):
                    Text("Connecting to \(deviceName)...")
                        .font(.system(size: 18, weight: .semibold))
                case .connected(let deviceName):
                    Text("Connected to \(deviceName)")
                        .font(.system(size: 18, weight: .semibold))
                case .failed(_, let error):
                    Text("Connection Failed")
                        .font(.system(size: 18, weight: .semibold))
                default:
                    Text("Select Device")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                if isScanning && connectionState == .disconnected {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
                
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                        .frame(width: 32, height: 32)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                        .clipShape(Circle())
                }
                .disabled({
                    if case .connecting = connectionState {
                        return true
                    }
                    return false
                }())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Connection Status or Device List
            if case .connecting = connectionState {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.top, 40)
                    
                    Text("Connecting to your Muse headband...")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if case .failed(_, let error) = connectionState {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                        .padding(.top, 40)
                    
                    VStack(spacing: 8) {
                        Text("Connection Failed")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        // Reset to try again
                        connectionState = .disconnected
                        connectionError = nil
                    }) {
                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.18, green: 0.41, blue: 0.77))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Device List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($devices) { $device in
                            DeviceRow(device: $device, 
                                     isSelected: selectedDevice?.id == device.id,
                                     isConnecting: connectionState == .connecting(deviceName: device.name)) {
                                selectedDevice = device
                                connectToDevice(device)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
            }
            
            // Scan Button
            Button(action: {
                // Start scanning for devices
                isScanning = true
                // Simulate scanning for devices
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isScanning = false
                    }
                }
            }) {
                HStack(spacing: 8) {
                    if isScanning {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text("Scan for device")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.18, green: 0.41, blue: 0.77))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 400)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            // Simulate device scanning
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isScanning = false
                }
            }
        }
    }
}

struct DeviceRow: View {
    @Binding var device: Device
    let isSelected: Bool
    let isConnecting: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Device icon
            Image("MuseIcon")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(8)
                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                
                HStack(spacing: 4) {
                    // Signal strength indicator
                    ForEach(1...3, id: \.self) { bar in
                        let isActive = bar <= device.signalStrength
                        let activeColor = Color(red: 0.18, green: 0.41, blue: 0.77)
                        let inactiveColor = Color(red: 0.9, green: 0.91, blue: 0.92)
                        let height = bar * 4 + 4
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isActive ? activeColor : inactiveColor)
                            .frame(width: 4, height: CGFloat(height))
                    }
                    
                    Text(device.isConnected ? "Connected" : "Not Connected")
                        .font(.system(size: 12))
                        .foregroundColor(device.isConnected ? 
                                       Color(red: 0.2, green: 0.78, blue: 0.35) : 
                                       Color(red: 0.6, green: 0.64, blue: 0.66))
                        .padding(.leading, 8)
                }
            }
            
            Spacer()
            
            // Selection/Connection indicator
            if isConnecting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.18, green: 0.41, blue: 0.77))
            }
        }
        .padding(12)
        .background(isSelected ? Color(red: 0.96, green: 0.97, blue: 1.0) : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(red: 0.18, green: 0.41, blue: 0.77) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            onSelect()
        }
    }
}

struct DeviceSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            DeviceSelectionView(isPresented: .constant(true))
        }
    }
}
