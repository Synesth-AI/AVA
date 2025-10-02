import Foundation

struct Device: Identifiable, Codable, Equatable {
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
    // Custom CodingKeys to ignore muse in Codable
    enum CodingKeys: String, CodingKey {
        case id, name, signalStrength, isConnected
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        signalStrength = try container.decode(Int.self, forKey: .signalStrength)
        isConnected = try container.decode(Bool.self, forKey: .isConnected)
        muse = nil // Not codable
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(signalStrength, forKey: .signalStrength)
        try container.encode(isConnected, forKey: .isConnected)
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
