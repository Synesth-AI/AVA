import Foundation


class MuseManager: NSObject, ObservableObject {
    static let shared = MuseManager()
    
    @Published var devices: [Device] = []
    @Published var connectionState: ConnectionState = .disconnected
    @Published var connectionError: String?
    
    private var museManager: IXNMuseManagerIos?
    private var connectionToken: IXNLogListener?
    private var currentMuse: IXNMuse?
    
    private override init() {
        super.init()
        setupMuseManager()
    }
    
    private func setupMuseManager() {
        museManager = IXNMuseManagerIos.sharedManager()
        museManager?.setMuseListener(self)
    }
    
    func startScanning() {
        devices.removeAll()
        connectionState = .disconnected
        museManager?.startListening()
    }
    
    func stopScanning() {
        museManager?.stopListening()
    }
    
    func connect(to device: Device) {
        guard let muse = devices.first(where: { $0.id == device.id })?.muse else { return }
        
        currentMuse = muse
        connectionState = .connecting(deviceName: device.name)
        
        muse.register(self)
        muse.runAsynchronously()
    }
    
    func disconnect() {
        currentMuse?.disconnect()
        currentMuse = nil
        connectionState = .disconnected
        MuseEEGReceiver.shared.stopStreaming()
    }
}

// MARK: - IXNMuseConnectionListener
extension MuseManager: IXNMuseConnectionListener {
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
        DispatchQueue.main.async {
            switch packet.currentConnectionState {
            case .disconnected:
                self.connectionState = .disconnected
                self.connectionError = "Disconnected from device"
                MuseEEGReceiver.shared.stopStreaming()
            case .connected:
                self.connectionState = .connected(deviceName: muse?.getName() ?? "Muse Device")
                if let muse = muse {
                    MuseEEGReceiver.shared.startStreaming(from: muse)
                }
            case .connecting:
                self.connectionState = .connecting(deviceName: muse?.getName() ?? "Muse Device")
            case .needsUpdate:
                self.connectionState = .failed(deviceName: muse?.getName() ?? "Muse Device", 
                                             error: "Device firmware needs update")
            case .unknown:
                self.connectionState = .failed(deviceName: muse?.getName() ?? "Muse Device", 
                                             error: "Unknown connection state")
            @unknown default:
                break
            }
        }
    }
}

// MARK: - IXNMuseListener
extension MuseManager: IXNMuseListener {
    func receive(_ packet: IXNMuseDataPacket, muse: IXNMuse?) {
        // Handle incoming data packets
        // You can implement this based on what data you need
    }
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        // Handle artifact packets
    }
    
    func museListChanged() {
        // Update devices list when Muse devices are discovered or removed
        DispatchQueue.main.async {
            guard let availableMuses = self.museManager?.getMuses() as? [IXNMuse] else { return }
            self.devices = availableMuses.map { Device(name: $0.getName(), muse: $0) }
        }
    }
}
