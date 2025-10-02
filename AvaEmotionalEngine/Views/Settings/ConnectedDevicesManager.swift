import Foundation
import SwiftUI
import AvaEmotionalEngine // Import the module to access Device model

class ConnectedDevicesManager: ObservableObject {
    @Published var devices: [Device] = []
    private let storageKey = "connectedDevices"
    
    init() {
        loadDevices()
    }
    
    func loadDevices() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Device].self, from: data) {
            devices = decoded
        }
    }
    
    func saveDevices() {
        if let encoded = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addDevice(_ device: Device) {
        if !devices.contains(where: { $0.name == device.name }) {
            devices.append(device)
            saveDevices()
        }
    }
    
    func removeDevice(_ device: Device) {
        devices.removeAll { $0.id == device.id }
        saveDevices()
    }
    
    func updateConnection(for device: Device, isConnected: Bool) {
        if let idx = devices.firstIndex(where: { $0.id == device.id }) {
            devices[idx].isConnected = isConnected
            saveDevices()
        }
    }
}
