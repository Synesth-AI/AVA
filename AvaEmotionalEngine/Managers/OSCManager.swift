import Foundation
import OSCKit

class OSCManager {
    static let shared = OSCManager()
    
    private var client: OSCUDPClient?
    private var isConnected = false
    
    private init() {
        // Initialize with default values
        updateConfig(host: EEGReading.oscHost, port: EEGReading.oscPort)
    }
    
    func sendEEGData(_ reading: EEGReading) {
        guard let client = client, isConnected else {
            print("OSC client not connected")
            return
        }
        
        // Send band powers
        let bandAddress = "\(EEGReading.oscBaseAddress)/bands"
        do {
            let bandMessage = OSCMessage(
                bandAddress,
                values: [
                    Double(reading.delta),
                    Double(reading.theta),
                    Double(reading.alpha),
                    Double(reading.beta),
                    Double(reading.gamma)
                ]
            )
            try? client.send(bandMessage, to: EEGReading.oscHost, port: EEGReading.oscPort)
        } catch {
            print("Error creating band message: \(error.localizedDescription)")
        }
        
        // Only send raw samples if we have data
        if !reading.rawSamples.isEmpty {
            let rawAddress = "\(EEGReading.oscBaseAddress)/raw"
            let rawValues = reading.rawSamples.map { Float($0) }
            do {
                let rawMessage = OSCMessage(rawAddress, values: rawValues.map { Double($0) })
                try? client.send(rawMessage, to: EEGReading.oscHost, port: EEGReading.oscPort)
            } catch {
                print("Error creating raw message: \(error.localizedDescription)")
            }
        }
        
        // Only send spectrum if we have data
        if !reading.spectrum.isEmpty {
            let spectrumAddress = "\(EEGReading.oscBaseAddress)/spectrum"
            let spectrumValues = reading.spectrum.map { Float($0) }
            do {
                let spectrumMessage = OSCMessage(spectrumAddress, values: spectrumValues.map { Double($0) })
                try? client.send(spectrumMessage, to: EEGReading.oscHost, port: EEGReading.oscPort)
            } catch {
                print("Error creating spectrum message: \(error.localizedDescription)")
            }
        }
    }
    
    func updateConfig(host: String, port: UInt16) {
        // Create new client with updated config
        // Using a random local port for sending
        client = OSCUDPClient()
        isConnected = true
    }
    
    func stop() {
        client = nil
        isConnected = false
    }
}
