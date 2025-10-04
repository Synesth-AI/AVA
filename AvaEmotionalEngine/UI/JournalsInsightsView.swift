import SwiftUI
import UIKit

struct JournalsInsightsView: View {
    @State private var selectedTab: JournalsTab = .trends
    enum JournalsTab: CaseIterable, Hashable { case patterns, trends }
    private let tabs: [JournalsTab] = JournalsTab.allCases
    
    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header
                tabsBar
                mainContent
                Spacer()
            }
            .padding(.top, safeTopInset + 8)
        }
    }

    // MARK: - Subviews (computed)
    private var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.98, green: 0.92, blue: 0.97), Color(red: 0.90, green: 0.95, blue: 1.0)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // Safe-area top inset via key window (works across iOS versions)
    private var safeTopInset: CGFloat {
        // Find the key window safely across scenes
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return keyWindow?.safeAreaInsets.top ?? 0
    }

    

    private var header: some View {
        HStack {
            Spacer()
            VStack(spacing: 2) {
                Text("Journals & Insights")
                    .font(.system(size: 24, weight: .bold))
                Text("Track patterns and reflect")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
                    // Avatar
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 2)
                Image(systemName: "face.smiling")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.pink)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var tabsBar: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.self) { tab in
                TabChip(
                    title: tab == .patterns ? "Patterns" : "Trends",
                    isSelected: selectedTab == tab,
                    action: { selectedTab = tab }
                )
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.3))
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 8)
    }

    private var mainContent: some View {
        Group {
            if selectedTab == .trends {
                TrendsScreen()
            } else {
                PatternsScreen()
            }
        }
    }
}

// Small subview used for tab buttons to simplify type-checking
private struct TabChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .black : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 28)
                .background(Color.white.opacity(isSelected ? 1.0 : 0.0))
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(isSelected ? 0.04 : 0.0), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Trends Screen

struct TrendsScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            // Weekly Report Title
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("Weekly Report")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 12)
            
            // Bar Chart
            BarChartView()
                .frame(height: 140)
                .padding(.top, 8)
            
            // Average Score
            HStack {
                Text("Average Score")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text("70")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.green.opacity(0.13))
                    )
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            // Suggested Habits
            VStack(alignment: .leading, spacing: 10) {
                Text("Suggested Habits")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.top, 18)
                    .padding(.bottom, 2)
                HabitCard(title: "Morning Calibration", subtitle: "5-min BreathSync before deep work", buttonTitle: "Try It")
                HabitCard(title: "Afternoon Reset", subtitle: "Brief walk when energy dips at 2 PM", buttonTitle: "Schedule")
                HabitCard(title: "Environment Sync", subtitle: "Auto-adjust lighting during focus sessions", buttonTitle: "Enable")
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)
        }
    }
}

struct BarChartView: View {
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let values: [CGFloat] = [40, 55, 60, 50, 90, 45, 30] // Friday is tallest
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            ForEach(0..<days.count, id: \.self) { i in
                VStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.pink.opacity(0.5)]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .frame(width: 18, height: values[i])
                    Text(days[i])
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

struct HabitCard: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "bolt.fill")
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {}) {
                Text(buttonTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Patterns Screen

struct PatternsScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            // Title and dropdown
            HStack {
                Text("Today’s Summary")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Menu {
                    Button("Today", action: {})
                    Button("Yesterday", action: {})
                } label: {
                    HStack(spacing: 2) {
                        Text("Today")
                            .font(.system(size: 15))
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 12)
            
            // Line Graph
            SimpleLineGraphView()
                .frame(height: 120)
                .padding(.top, 8)
  
          
            // Insight Cards
            VStack(spacing: 12) {
                InsightCard(
                    title: "Peak Focus Window",
                    description: "You perform best between 9:00-11:00 AM with an average focus score of 84."
                )
                InsightCard(
                    title: "Intervention Effectiveness",
                    description: "Calming audio sounds improve your score by 12 points."
                )
                InsightCard(
                    title: "Recovery Pattern",
                    description: "Your calm score peaks after 5-minute breaks, ideal for restoration."
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}

struct SimpleLineGraphView: View {
    // Example data for smooth blue wave and intervention points
    let points: [CGFloat] = [30, 50, 80, 60, 90, 70, 60, 80, 70, 60, 50, 40, 30]
    let interventionIndices: [Int] = [2, 5, 8]
    let times = ["03:00", "", "05:00", "", "07:00", "", "09:00"]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Line graph
                Path { path in
                    let width = geo.size.width
                    let height = geo.size.height
                    let step = width / CGFloat(points.count - 1)
                    path.move(to: CGPoint(x: 0, y: height - points[0]))
                    for i in 1..<points.count {
                        path.addLine(to: CGPoint(x: CGFloat(i) * step, y: height - points[i]))
                    }
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.pink.opacity(0.5)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                
                // Intervention points
                ForEach(interventionIndices, id: \.self) { idx in
                    let width = geo.size.width
                    let height = geo.size.height
                    let step = width / CGFloat(points.count - 1)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .position(x: CGFloat(idx) * step, y: height - points[idx])
                }
                
                // X-axis labels
                HStack {
                    ForEach(0..<times.count, id: \.self) { i in
                        Text(times[i])
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                .offset(y: 18)
            }
        }
        .padding(.horizontal, 12)
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

struct JournalsInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsInsightsView()
    }
}
