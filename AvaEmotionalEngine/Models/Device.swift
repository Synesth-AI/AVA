import Foundation

struct Device: Identifiable, Equatable {
    let id: UUID
    let name: String
    let signalStrength: Int
    var isConnected: Bool
    let muse: IXNMuse?
    
    init(name: String, signalStrength: Int = 3, isConnected: Bool = false, muse: IXNMuse? = nil) {
        self.id = UUID()
        self.name = name
        self.signalStrength = signalStrength
        self.isConnected = isConnected
        self.muse = muse
    }
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ConnectionState: Equatable {
    case disconnected
    case connecting(deviceName: String)
    case connected(deviceName: String)
    case failed(deviceName: String, error: String)
    
    var deviceName: String {
        switch self {
        case .connecting(let name), .connected(let name), .failed(let name, _):
            return name
        default:
            return ""
        }
    }
    
    var isConnecting: Bool {
        if case .connecting = self {
            return true
        }
        return false
    }
}

// Extension to handle connection state changes
extension ConnectionState {
    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case let .failed(_, error) = self {
            return error
        }
        return nil
    }
}
