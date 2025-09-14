import Foundation
import Combine

class MetricsManager: ObservableObject {
    static let shared = MetricsManager()
    
    @Published var krScore: Double = 0.0 // Normalized 0-1 value
    @Published var rawKrScore: Double = 0.0 // Unscaled raw KXRP score
    @Published var lastUpdate: Date = Date()
    @Published var selectedEquationIndex: Int = 1
    
    // Score history for the current session
    @Published private(set) var scoreHistory: [Double] = []
    private let maxHistoryCount = 100 // Maximum number of scores to keep in history
    
    // Available KXRP equations
    let availableEquations: [KXRPEquation] = KXRPEquation.sampleEquations
    
    private let userDefaultsKey = "SelectedEquationIndex"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Load saved equation preference if available
        if let savedIndex = UserDefaults.standard.object(forKey: userDefaultsKey) as? Int {
            selectedEquationIndex = savedIndex
        }
        
        // Save equation preference when it changes
        $selectedEquationIndex
            .dropFirst()
            .sink { [weak self] newValue in
                guard let self = self else { return }
                UserDefaults.standard.set(newValue, forKey: self.userDefaultsKey)
            }
            .store(in: &cancellables)
        
        // Generate some sample data for the graph
        generateSampleData()
    }
    
    func updateMetrics(psi: Double, kxrpScores: [Double]) {
        // Get the score based on the selected equation index
        let scoreIndex = selectedEquationIndex - 1 // Convert to 0-based index
        let newScore: Double
        
        // If the selected equation is within the available scores range, use it
        if scoreIndex >= 0 && scoreIndex < kxrpScores.count {
            newScore = kxrpScores[scoreIndex]
        } else if selectedEquationIndex == 50 {
            // Special case for Omega Integration (equation 50)
            // It's calculated differently in KXRPEquationBank
            newScore = kxrpScores.last ?? psi
        } else {
            // Fallback to PSI if selected equation is not available
            newScore = psi
        }
        
        rawKrScore = newScore
        
        // Calculate the normalized score (0-1)
        let normalizedScore = min(max(newScore / 100.0, 0), 1.0)
        
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.krScore = normalizedScore
            self.lastUpdate = Date()
            
            // Add to score history
            self.scoreHistory.append(normalizedScore)
            
            // Trim history if needed
            if self.scoreHistory.count > self.maxHistoryCount {
                self.scoreHistory.removeFirst(self.scoreHistory.count - self.maxHistoryCount)
            }
        }
    }
    
    // Generate sample data for the graph
    private func generateSampleData() {
        // Generate 24 hours of sample data
        let hoursInDay = 24
        let now = Date()
        let calendar = Calendar.current
        
        for hour in 0..<hoursInDay {
            if let date = calendar.date(byAdding: .hour, value: -hoursInDay + hour, to: now) {
                // Generate a value between 0.3 and 0.9 with some variation
                let baseValue = 0.3 + 0.6 * Double(arc4random_uniform(100)) / 100.0
                let variation = sin(Double(hour) * .pi / 12.0) * 0.2 // Daily pattern
                let value = max(0.0, min(1.0, baseValue + variation))
                
                // Add some random noise
                let noise = (Double(arc4random_uniform(20)) - 10.0) / 100.0
                let finalValue = max(0.0, min(1.0, value + noise))
                
                scoreHistory.append(finalValue)
            }
        }
        
        // Ensure we have some initial data
        if scoreHistory.isEmpty {
            scoreHistory = [0.5, 0.6, 0.7, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.85, 0.8]
        }
    }
    
    // Get the score history for the graph
    func getScoreHistory() -> [Double] {
        // If we don't have enough history, use the sample data
        if scoreHistory.isEmpty {
            generateSampleData()
        }
        
        // Return the last 24 data points or all if less than 24
        let count = min(24, scoreHistory.count)
        return Array(scoreHistory.suffix(count))
    }
}
