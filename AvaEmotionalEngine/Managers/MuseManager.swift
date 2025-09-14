import Foundation
import UIKit


class MuseManager: NSObject, ObservableObject {
    static let shared = MuseManager()
    
    @Published var devices: [Device] = []
    @Published var connectionState: ConnectionState = .disconnected
    @Published var connectionError: String?
    @Published var batteryLevel: Int = 0
    
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
        
        // Register for battery updates
        muse.register(self, type: .battery)
        muse.register(self)
        muse.runAsynchronously()
        
        // Start battery level monitoring
        startBatteryMonitoring()
    }
    
    func disconnect() {
        currentMuse?.disconnect()
        currentMuse = nil
        connectionState = .disconnected
        batteryLevel = 0
        MuseEEGReceiver.shared.stopStreaming()
    }
    
    private func startBatteryMonitoring() {
        // Request battery level updates every 60 seconds
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.currentMuse?.register(self, type: .battery)
            // The battery level will be updated in the receive(_:muse:) method
        }.fire()
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
                self.connectionState = .failed(deviceName: muse?.getName() ?? "Muse Device", 
                                             error: "Unknown connection state: \(packet.currentConnectionState.rawValue)")
                break
            }
        }
    }
}

// MARK: - IXNMuseListener
extension MuseManager: IXNMuseListener {
    @objc func receiveMuseDataPacket(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        // Handle incoming data packets
        guard let packet = packet, packet.packetType() == .battery else { return }
        
        // Get battery percentage from the packet
        let batteryPercentage = packet.getBatteryValue(.chargePercentageRemaining)
        if batteryPercentage > 0 {
            DispatchQueue.main.async {
                self.batteryLevel = Int(batteryPercentage)
            }
        }
    }
    
    @objc func receiveMuseArtifactPacket(_ packet: IXNMuseArtifactPacket?, muse: IXNMuse?) {
        // Handle artifact packets
    }
    
    @objc func museListChanged() {
        // Update devices list when Muse devices are discovered or removed
        DispatchQueue.main.async {
            guard let availableMuses = self.museManager?.getMuses() as? [IXNMuse] else { return }
            self.devices = availableMuses.map { Device(name: $0.getName(), muse: $0) }
        }
    }
}

// MARK: - IXNMuseDataListener
extension MuseManager: IXNMuseDataListener {
}
