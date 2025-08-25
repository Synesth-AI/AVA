import Foundation
import Combine

class MetricsManager: ObservableObject {
    static let shared = MetricsManager()
    
    @Published var krScore: Double = 0.0 // Normalized 0-1 value
    @Published var rawKrScore: Double = 0.0 // Unscaled raw KXRP score
    @Published var lastUpdate: Date = Date()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // You can add any setup code here if needed
    }
    
    func updateMetrics(psi: Double, kxrpScores: [Double]) {
        // Use the first KXRP score as the KR score
        // You can modify this logic based on which score you want to use
        let newScore = kxrpScores.first ?? psi
        rawKrScore = newScore
        
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            // Simple scaling: assume 0-100 range; adjust as needed
            self?.krScore = min(max(newScore / 100.0, 0), 1.0)
            self?.lastUpdate = Date()
        }
    }
}
