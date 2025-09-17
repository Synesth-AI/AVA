import SwiftUI
import Combine

private struct BatteryIndicatorView: View {
    @ObservedObject private var museManager = MuseManager.shared
    
    private var batteryLevel: Int {
        museManager.batteryLevel
    }
    
    private var batteryIcon: String {
        switch batteryLevel {
        case 0..<20: return "battery.0"
        case 20..<40: return "battery.25"
        case 40..<60: return "battery.50"
        case 60..<80: return "battery.75"
        default: return "battery.100"
        }
    }
    
    private var textColor: Color {
        batteryLevel < 20 ? .red : .black
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: batteryIcon)
                .foregroundColor(textColor)
            
            Text("\(batteryLevel)%")
                .font(.caption)
                .foregroundColor(textColor)
                .frame(minWidth: 30, alignment: .trailing)
        }
    }
}

struct HomeView: View {
    @State private var isShowingEquationSelection = false
    @EnvironmentObject var appState: AppState
    @StateObject private var metricsManager = MetricsManager.shared
    @State private var selectedTab: Tab = .home
    @State private var showLiveData = false
    @State private var isShowingLiveDataSelector = false
    
    // Map KR score to a descriptive label and color
    // KR score ranges from 0.0-1.0, where:
    // 0.0-0.3: Low engagement/arousal
    // 0.3-0.6: Moderate engagement
    // 0.6-1.0: High engagement/arousal
    private func krScoreLabel(for score: Double) -> (text: String, color: Color) {
        switch score {
        case 0.0..<0.3: return ("😴 Resting", .blue) // Deep rest/low engagement
        case 0.3..<0.45: return ("😌 Calm", .teal) // Light engagement, relaxed focus
        case 0.45..<0.6: return ("🤔 Attentive", .green) // Moderate engagement, good for learning
        case 0.6..<0.75: return ("🎯 Focused", .yellow) // High engagement, ideal for tasks
        case 0.75...1.0: return ("⚡ Energized", .orange) // Very high engagement/arousal
        default: return ("❓ Unknown", .gray)
        }
    }
    
    private func getScoreDescription() -> String {
        switch metricsManager.krScore {
        case 0.0..<0.3: 
            return "Your mind is in a deep rest state. Ideal for relaxation, meditation, or recovery periods."
            
        case 0.3..<0.45: 
            return "You're in a calm, relaxed state. Good for light activities, creative thinking, or casual conversations."
            
        case 0.45..<0.6: 
            return "You're alert and attentive. This is a great state for learning, reading, or engaging in meaningful discussions."
            
        case 0.6..<0.75: 
            return "You're highly focused and engaged. Perfect for tasks requiring concentration, problem-solving, or physical activity."
            
        case 0.75...1.0: 
            return "You're in a high-energy state. Use this energy for intense tasks, workouts, or creative bursts."
            
        default: 
            return "Your KR score is currently unavailable."
        }
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    var body: some View {
        // This will cause the view to update when metricsManager's published properties change
        let _ = metricsManager.objectWillChange.sink { _ in
            print("Metrics updated - KR Score: \(metricsManager.krScore)")
        }
        
        let scoreLabel = krScoreLabel(for: metricsManager.krScore)
        
        ZStack(alignment: .bottom) {
            // Main scrollable content
            ScrollView {
                VStack(spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hi \(appState.userName.isEmpty ? "there" : appState.userName)")
                        .font(.title2).fontWeight(.semibold)
                    Text("Sunday 17th June, 2025")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 16) {
                    // Battery indicator
                    if MuseManager.shared.connectionState.isConnected && MuseManager.shared.batteryLevel > 0 {
                        BatteryIndicatorView()
                    }
                    
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 20)
                }
            }
            .padding([.horizontal, .top])

            // Live Data Card
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black)
                    .frame(height: 480)
                
                // Header with title and toggle button
                HStack {
                    Text(showLiveData ? "Live Brain Waves" : "Live KR Score")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.leading, 16)
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    // Toggle Button
                    Button(action: {
                        withAnimation {
                            showLiveData.toggle()
                        }
                    }) {
                        Image(systemName: showLiveData ? "chart.pie" : "waveform.path.ecg")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                
                VStack(spacing: 8) {
                    Spacer()
                    
                    if showLiveData {
                        // Live Data Visualization
                        VStack(spacing: 4) {
                            // Connection status is now handled in the LiveEEGStreamView
                            LiveEEGStreamView()
                                .frame(height: 320)
                                .padding(.horizontal, 4)
                        }
                    } else {
                        // Animated circle visualization
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 6)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(metricsManager.krScore, 1.0)))
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.purple.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 80, height: 80)
                                .rotationEffect(Angle(degrees: -90))
                                .animation(.easeInOut(duration: 1.0), value: metricsManager.krScore)
                            
                            VStack(spacing: 2) {
                                Text(String(format: "%.2f", metricsManager.krScore))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(String(format: "Raw: %.2f", metricsManager.rawKrScore))
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Text(scoreLabel.text)
                            .font(.headline)
                            .foregroundColor(scoreLabel.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(scoreLabel.color.opacity(0.2))
                            .cornerRadius(12)
                        
                        // Equation selection button
                        Button(action: {
                            isShowingEquationSelection = true
                        }) {
                            HStack {
                                Text("KXRP \(metricsManager.selectedEquationIndex)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    
                    Text(getScoreDescription())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // What you need now
            VStack(spacing: 4) {
                Text("Here's what you need now")
                    .font(.headline)
                Text("No action needed")
                    .foregroundColor(.gray)
            }
            .padding(.top, 18)

            // Activate button
            Button(action: {}) {
                Text("Activate")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // State Forecast Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("State Forecast")
                        .font(.subheadline).fontWeight(.semibold)
                    Spacer()
                    Button("Schedule") {}
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                Divider()
                Text("\u{2198} Focus dip predicted")
                    .font(.caption)
                    .foregroundColor(.red)
                Text("Next 20 minutes\nConsider Taking a break\nCalm background music")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.blue.opacity(0.08))
            .cornerRadius(14)
            .padding([.horizontal, .top])

            // Today's Summary Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Summary")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("KXRP \(metricsManager.selectedEquationIndex)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Line Graph
                VStack(spacing: 4) {
                    // Graph with score history
                    if !metricsManager.getScoreHistory().isEmpty {
                        LineGraphView(
                            data: metricsManager.getScoreHistory(),
                            lineColor: scoreLabel.color,
                            lineWidth: 2.0,
                            showDots: false
                        )
                        .frame(height: 80)
                        .padding(.horizontal, 8)
                        
                        // Time markers
                        HStack {
                            Text("12h")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("6h")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Now")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                    } else {
                        // Show placeholder when no data is available
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 80)
                            .overlay(
                                VStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("No data available yet")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                }
                
                // Stats Row
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Score")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(String(format: "%.2f", metricsManager.krScore))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Peak Today")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text(metricsManager.getScoreHistory().max().map { String(format: "%.2f", $0) } ?? "0.00")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg. Score")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        let avg = metricsManager.getScoreHistory().reduce(0, +) / max(1, Double(metricsManager.getScoreHistory().count))
                        Text(String(format: "%.2f", avg))
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .padding(.top, 4)
                
                // View Details Button
                Button(action: {
                    // Action to view more detailed stats
                }) {
                    HStack {
                        Text("View Detailed Analysis")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .padding([.horizontal, .top])
        }
        .frame(maxWidth: .infinity)
    }
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white,
                Color.purple.opacity(0.08),
                Color.blue.opacity(0.08)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    )
    .sheet(isPresented: $isShowingEquationSelection) {
            NavigationView {
                EquationSelectionView()
                    .navigationBarTitle("Select Equation", displayMode: .inline)
                    .navigationBarItems(trailing: Button("Done") {
                        isShowingEquationSelection = false
                    })
            }
        }
        .sheet(isPresented: $isShowingLiveDataSelector) {
            NavigationView {
                LiveDataSelectorView()
                    .navigationBarTitle("Select Live Data", displayMode: .inline)
                    .navigationBarItems(trailing: Button("Done") {
                        isShowingLiveDataSelector = false
                    })
            }
        }
        .safeAreaInset(edge: .bottom) {
            // Bottom Navigation Bar
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                HStack(spacing: 0) {
                    // Home Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = .home
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: Tab.home.rawValue)
                                .font(.system(size: 22))
                            Text(Tab.home.title)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(selectedTab == .home ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    
                    // Sessions Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = .sessions
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: Tab.sessions.rawValue)
                                .font(.system(size: 22))
                            Text(Tab.sessions.title)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(selectedTab == .sessions ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    
                    // Journal Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = .journal
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: Tab.journal.rawValue)
                                .font(.system(size: 22))
                            Text(Tab.journal.title)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(selectedTab == .journal ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    
                    // Sync Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = .sync
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: Tab.sync.rawValue)
                                .font(.system(size: 22))
                            Text(Tab.sync.title)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(selectedTab == .sync ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(
                    Color(UIColor.systemBackground)
                        .edgesIgnoringSafeArea(.bottom)
                )
            }
        }
        .sheet(isPresented: $isShowingLiveDataSelector) {
            LiveDataSelectorView()
        }
    }
}

#Preview {
    let appState = AppState()
    appState.userName = "Isaac" // Provide a default name for preview
    
    // Set up a test metrics manager
    let metricsManager = MetricsManager.shared
    metricsManager.updateMetrics(psi: 72.5, kxrpScores: [72.5, 68.2, 75.0])
    
    return HomeView()
        .environmentObject(appState)
        .environmentObject(metricsManager)
}
