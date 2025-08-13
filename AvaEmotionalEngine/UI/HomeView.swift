import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var metricsManager = MetricsManager.shared
    
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
    
    var body: some View {
        // This will cause the view to update when metricsManager's published properties change
        let _ = metricsManager.objectWillChange.sink { _ in
            print("Metrics updated - KR Score: \(metricsManager.krScore)")
        }
        
        let scoreLabel = krScoreLabel(for: metricsManager.krScore)
        
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)
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
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .padding([.horizontal, .top])

            // Live KR Score Card
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black)
                    .frame(height: 240)
                VStack(spacing: 8) {
                    Text("Live KR Score")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.top, 16)
                    Spacer()
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
                        
                        Text(String(format: "%.2f", metricsManager.krScore))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 12) {
                        Text(scoreLabel.text)
                            .font(.headline)
                            .foregroundColor(scoreLabel.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(scoreLabel.color.opacity(0.2))
                            .cornerRadius(12)
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
                
                // Top right time badge
                Text(getCurrentTime())
                    .font(.caption2)
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding([.top, .trailing], 12)
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
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Summary")
                    .font(.subheadline).fontWeight(.semibold)
                // Placeholder for chart
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 60)
                    .overlay(Text("[Graph]").foregroundColor(.gray))
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Peak Focus Time")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("9:15 - 10:45 AM")
                            .font(.caption2)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Interventions Triggered")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("3")
                            .font(.caption2)
                    }
                }
                Button(action: {}) {
                    Text("View Details")
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .padding([.horizontal, .top])

            Spacer()

            // Bottom Nav Bar
            HStack {
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home").font(.caption2)
                }
                .foregroundColor(.blue)
                Spacer()
                VStack {
                    Image(systemName: "timer")
                    Text("Sessions").font(.caption2)
                }
                Spacer()
                VStack {
                    Image(systemName: "book.closed")
                    Text("Journal").font(.caption2)
                }
                Spacer()
                VStack {
                    Image(systemName: "arrow.2.circlepath")
                    Text("Sync").font(.caption2)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.purple.opacity(0.08), Color.blue.opacity(0.08)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

// Helper extensions for the view
private extension HomeView {
    func getScoreDescription() -> String {
        switch metricsManager.krScore {
        case 0.0..<0.3: 
            return "Your mind is in a deep rest state. Ideal for relaxation, meditation, or recovery periods."
            
        case 0.3..<0.45: 
            return "You're in a calm, relaxed state. Good for light activities, creative thinking, or casual conversations."
            
        case 0.45..<0.6: 
            return "You're alert and attentive. This is a great state for learning, reading, or engaging in meaningful discussions."
            
        case 0.6..<0.75: 
            return "You're highly focused and engaged. Perfect for problem-solving, deep work, or tasks requiring sustained attention."
            
        case 0.75...1.0: 
            return "You're in a state of high energy and intensity. Best for activities requiring peak performance or quick reactions."
            
        default: 
            return "Analyzing your current cognitive state..."
        }
    }
    
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
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
