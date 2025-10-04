import Foundation
import UIKit


class MuseManager: NSObject, ObservableObject {
    static let shared = MuseManager()
    
    @Published var devices: [Device] = []
    @Published var connectionState: ConnectionState = .disconnected
    @Published var connectionError: String?
    @Published var batteryLevel: Int = 0
    @Published var isScanning: Bool = false
    
    private var museManager: IXNMuseManagerIos?
    private var connectionToken: IXNLogListener?
    private var currentMuse: IXNMuse?
    private var discoveryTimer: Timer?
    
    private override init() {
        super.init()
        setupMuseManager()
    }
    
    private func setupMuseManager() {
        museManager = IXNMuseManagerIos.sharedManager()
        museManager?.setMuseListener(self)
    }
    
    func startScanning() {
        print("[MuseManager] startScanning called")
        // If already connected, do not clear list or reset state, and skip scanning
        if connectionState.isConnected {
            print("[MuseManager] already connected — skipping scan")
            return
        }
        devices.removeAll()
        connectionState = .disconnected
        isScanning = true
        museManager?.startListening()

        // Fallback polling: query available muses periodically for a short window
        discoveryTimer?.invalidate()
        var ticks = 0
        discoveryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            ticks += 1
            if let available = self.museManager?.getMuses() as? [IXNMuse] {
                let mapped = available.map { Device(name: $0.getName(), muse: $0) }
                if self.devices.map({ $0.name }) != mapped.map({ $0.name }) {
                    print("[MuseManager] polling found devices: \(mapped.map{ $0.name })")
                }
                DispatchQueue.main.async {
                    self.devices = mapped
                    if !mapped.isEmpty { self.isScanning = false }
                }
            }
            if ticks >= 10 || self.connectionState.isConnected {
                timer.invalidate()
                self.discoveryTimer = nil
                self.isScanning = false
            }
        }
    }
    
    func stopScanning() {
        print("[MuseManager] stopScanning called")
        isScanning = false
        museManager?.stopListening()
        discoveryTimer?.invalidate()
        discoveryTimer = nil
    }
    
    func connect(to device: Device) {
        guard let muse = devices.first(where: { $0.id == device.id })?.muse else { return }
        // Stop scanning while attempting to connect
        stopScanning()
        
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
        // Optionally resume scanning after disconnect if desired
        // isScanning = false
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
                // Ensure scanning flag is off after disconnection (do not auto-restart)
                self.isScanning = false
            case .connected:
                self.connectionState = .connected(deviceName: muse?.getName() ?? "Muse Device")
                if let muse = muse {
                    MuseEEGReceiver.shared.startStreaming(from: muse)
                }
                // Stop scanning once connected
                self.stopScanning()
                self.discoveryTimer?.invalidate()
                self.discoveryTimer = nil
                // Ensure the connected device appears in the devices list even without scanning
                if let muse = muse {
                    let name = muse.getName()
                    let connectedDevice = Device(name: name, isConnected: true, muse: muse)
                    // Replace list with the connected device if it's not already present
                    if !self.devices.contains(where: { $0.name == name }) {
                        self.devices = [connectedDevice]
                    } else {
                        // Update existing entry to mark connected
                        self.devices = self.devices.map { d in
                            if d.name == name { var nd = d; nd.isConnected = true; return nd } else { return d }
                        }
                    }
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
            print("[MuseManager] museListChanged fired")
            guard let availableMuses = self.museManager?.getMuses() as? [IXNMuse] else { return }
            self.devices = availableMuses.map { Device(name: $0.getName(), muse: $0) }
            self.isScanning = false
            print("[MuseManager] devices count: \(self.devices.count)")
        }
    }
}

// MARK: - IXNMuseDataListener
extension MuseManager: IXNMuseDataListener {
}
