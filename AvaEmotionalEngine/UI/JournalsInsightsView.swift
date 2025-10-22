import SwiftUI

struct JournalsInsightsView: View {
    @State private var selectedTab: JournalsTab = .patterns
    @EnvironmentObject private var metricsManager: MetricsManager
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
            .padding(.top, 60)
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

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Journals & Insights")
                    .font(.system(size: 24, weight: .bold))
                Text("Track patterns and reflect")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            // Profile Avatar
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.gray.opacity(0.6))
                    .clipShape(Circle())
            }
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 16)
    }

    private var tabsBar: some View {
        Picker("Select Tab", selection: $selectedTab) {
            Text("Patterns").tag(JournalsTab.patterns)
            Text("Trends").tag(JournalsTab.trends)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 32)
        .padding(.vertical, 8)
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

// MARK: - Trends Screen

struct TrendsScreen: View {
    @State private var selectedWeek: Date = Date() // Start with current week
    @EnvironmentObject private var metricsManager: MetricsManager

    private var currentWeek: Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }

    private var isCurrentWeek: Bool {
        let calendar = Calendar.current
        let selectedWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedWeek))!
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return calendar.isDate(selectedWeekStart, inSameDayAs: currentWeekStart)
    }

    private var weekDateRange: String {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedWeek))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }

    private func goToPreviousWeek() {
        let calendar = Calendar.current
        selectedWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedWeek)!
    }

    private func goToNextWeek() {
        let calendar = Calendar.current
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let selectedWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedWeek))!

        // Only allow navigation if not already on current week
        if !calendar.isDate(selectedWeekStart, inSameDayAs: currentWeekStart) {
            selectedWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedWeek)!
        }
    }

    private func calculateWeeklyAverage() -> Double {
        // For now, return a sample calculation
        // In a real implementation, this would calculate the average from the actual weekly data
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedWeek))!

        // Sample calculation - in real app this would use actual historical data
        let baseScore = metricsManager.krScore
        let variation = Double.random(in: -0.1...0.1)
        return max(0, min(100, (baseScore + variation) * 100))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Weekly Report Title with date range
            HStack {
                Button(action: goToPreviousWeek) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("Weekly Report")
                        .font(.system(size: 18, weight: .semibold))
                    Text(weekDateRange)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: goToNextWeek) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(isCurrentWeek ? .gray.opacity(0.3) : .gray)
                }
                .disabled(isCurrentWeek) // Disable when on current week
            }
            .padding(.horizontal, 32)
            .padding(.top, 12)

            // Bar Chart with dynamic data for selected week
            DynamicBarChartView(selectedWeek: selectedWeek)
                .frame(height: 140)
                .padding(.top, 8)

            // Average Score for the selected week
            HStack {
                Text("Average Score")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                let weeklyAverage = calculateWeeklyAverage()
                Text(String(format: "%.0f", weeklyAverage))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(weeklyAverage >= 70 ? .green : weeklyAverage >= 50 ? .yellow : .red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill((weeklyAverage >= 70 ? Color.green : weeklyAverage >= 50 ? Color.yellow : Color.red).opacity(0.13))
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

struct DynamicBarChartView: View {
    let selectedWeek: Date
    @EnvironmentObject private var metricsManager: MetricsManager

    private var weeklyData: [Double] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedWeek))!

        // Generate sample data for each day of the week
        // In a real implementation, this would fetch actual historical data
        return (0..<7).map { day in
            let dayScore = metricsManager.krScore + Double.random(in: -0.2...0.2)
            return max(0, min(1, dayScore)) * 100 // Convert to 0-100 range
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            ForEach(0..<7, id: \.self) { dayIndex in
                let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                let value = weeklyData[dayIndex]

                VStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.pink.opacity(0.5)]),
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .frame(width: 18, height: CGFloat(value))
                    Text(dayNames[dayIndex])
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
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
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @EnvironmentObject private var metricsManager: MetricsManager

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }

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

    private func getScoreDescription(for score: Double) -> String {
        switch score {
        case 0.0..<0.3:
            return "Deep rest state"
        case 0.3..<0.45:
            return "Calm and relaxed"
        case 0.45..<0.6:
            return "Alert and attentive"
        case 0.6..<0.75:
            return "Highly focused"
        case 0.75...1.0:
            return "High energy state"
        default:
            return "Unknown state"
        }
    }

    var body: some View {
        // This will cause the view to update when metricsManager's published properties change
        let _ = metricsManager.objectWillChange.sink { _ in
            print("Journals metrics updated - KR Score: \(metricsManager.krScore)")
        }
        
        let scoreLabel = krScoreLabel(for: metricsManager.krScore)
        VStack(spacing: 0) {
            // Title and date picker
            HStack {
                Text("Summary")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button(action: {
                    showingDatePicker = true
                }) {
                    HStack(spacing: 2) {
                        Text(formattedDate)
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
            
            // Line Graph - EXACT SAME as home page
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

                    // Time markers - EXACT SAME as home page
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
                    // Show placeholder when no data is available - EXACT SAME as home page
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
            .padding(.top, 24)  // Add space between header and graph
  
          
            // Insight Cards
            VStack(spacing: 12) {
                InsightCard(
                    title: "Peak Focus Window",
                    description: "You perform best between 9:00-11:00 AM with an average focus score of \(String(format: "%.0f", metricsManager.krScore * 100))."
                )
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

                InsightCard(
                    title: "Current State",
                    description: "\(getScoreDescription(for: metricsManager.krScore)) with a score of \(String(format: "%.2f", metricsManager.krScore))."
                )
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

                InsightCard(
                    title: "Data Availability",
                    description: "\(metricsManager.getScoreHistory().count > 0 ? "\(metricsManager.getScoreHistory().count) data points recorded today" : "No data recorded for \(formattedDate)")"
                )
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .sheet(isPresented: $showingDatePicker) {
            VStack {
                Text("Select Date")
                    .font(.headline)
                    .padding()

                DatePicker("Choose Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()

                Spacer()

                Button("Done") {
                    showingDatePicker = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .presentationDetents([.medium])
        }
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
        .frame(maxWidth: .infinity, alignment: .leading)
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
            .environmentObject(MetricsManager.shared)
    }
}
