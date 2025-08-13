import Foundation
import Combine

class MetricsManager: ObservableObject {
    static let shared = MetricsManager()
    
    @Published var krScore: Double = 50.0 // Default value, will be updated
    @Published var lastUpdate: Date = Date()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // You can add any setup code here if needed
    }
    
    func updateMetrics(psi: Double, kxrpScores: [Double]) {
        // Use the first KXRP score as the KR score
        // You can modify this logic based on which score you want to use
        let newScore = kxrpScores.first ?? psi
        
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            self?.krScore = min(max(newScore, 0), 1.0) // Clamp between 0-1
            self?.lastUpdate = Date()
        }
    }
}
