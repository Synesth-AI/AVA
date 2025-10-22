import SwiftUI

struct SessionsView: View {
    @State private var selectedSessionType: SessionType?
    @State private var showingDatePicker = false
    @EnvironmentObject private var metricsManager: MetricsManager

    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }

    enum SessionType {
        case focus, mood, recovery

        var title: String {
            switch self {
            case .focus: return "Enhanced Focus"
            case .mood: return "Mood Balance"
            case .recovery: return "Recovery"
            }
        }

        var color: Color {
            switch self {
            case .focus: return Color(red: 0.6, green: 0.7, blue: 1.0) // Light Blue/Purple
            case .mood: return Color(red: 0.8, green: 0.7, blue: 1.0) // Light Lavender/Purple
            case .recovery: return Color(red: 1.0, green: 0.9, blue: 0.6) // Soft Yellow/Gold
            }
        }

        var icon: String {
            switch self {
            case .focus: return "circle.circle"
            case .mood: return "lightbulb"
            case .recovery: return "bed.double"
            }
        }

        var description: String {
            switch self {
            case .focus: return "Deep concentration and mental clarity"
            case .mood: return "Emotional regulation and mindfulness"
            case .recovery: return "Rest and mental restoration"
            }
        }
    }

    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.92, blue: 0.97),
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Main content
            VStack(spacing: 0) {
                // Header
                header

                // Content area
                ScrollView {
                    VStack(spacing: 24) {
                        // Session Selection Cards
                        VStack(spacing: 16) {
                            ForEach([SessionType.focus, .mood, .recovery], id: \.self) { sessionType in
                                SessionSelectionCard(
                                    sessionType: sessionType,
                                    isSelected: selectedSessionType == sessionType
                                )
                                .onTapGesture {
                                    selectedSessionType = sessionType
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Start Session Button
                        Button(action: {
                            // Start session logic will go here
                            print("Starting \(selectedSessionType?.title ?? "Unknown") session")
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Start Session")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.6, blue: 1.0),
                                        Color(red: 0.6, green: 0.4, blue: 1.0)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .disabled(selectedSessionType == nil)
                        .opacity(selectedSessionType == nil ? 0.6 : 1.0)

                        // Completed Sessions Section
                        VStack(alignment: .leading, spacing: 16) {
                            // Section Header with Date Filter
                            HStack {
                                Text("Completed Sessions")
                                    .font(.system(size: 20, weight: .semibold))
                                Spacer()
                                Button(action: {
                                    showingDatePicker = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text(currentDate)
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }

                            // Completed Session Cards
                            VStack(spacing: 12) {
                                ForEach([
                                    (type: SessionType.focus, duration: "25 min", time: "2:30 PM"),
                                    (type: SessionType.mood, duration: "15 min", time: "11:45 AM"),
                                    (type: SessionType.recovery, duration: "30 min", time: "8:00 AM")
                                ], id: \.time) { session in
                                    CompletedSessionCard(
                                        sessionType: session.type,
                                        duration: session.duration,
                                        time: session.time
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    }
                    .padding(.bottom, 100) // Space for bottom safe area
                }
            }
            .padding(.top, 45) // ← SAME as Journals screen
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingDatePicker) {
            VStack {
                Text("Select Date")
                    .font(.headline)
                    .padding()

                DatePicker("Choose Date", selection: .constant(Date()), in: ...Date(), displayedComponents: .date)
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

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Session Tracking")
                    .font(.system(size: 28, weight: .bold))
                Text("Brain wave guided sessions")
                    .font(.system(size: 15))
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
        .padding(.bottom, 20)
    }
}

struct SessionSelectionCard: View {
    let sessionType: SessionsView.SessionType
    let isSelected: Bool

    var body: some View {
        HStack {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(sessionType.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: sessionType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(sessionType.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(sessionType.title)
                    .font(.system(size: 18, weight: .semibold))
                Text(sessionType.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Selection indicator
            Circle()
                .stroke(isSelected ? sessionType.color : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .fill(isSelected ? sessionType.color : Color.clear)
                        .frame(width: 8, height: 8)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? sessionType.color : Color.clear, lineWidth: 2)
        )
    }
}

struct CompletedSessionCard: View {
    let sessionType: SessionsView.SessionType
    let duration: String
    let time: String

    var body: some View {
        HStack {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(sessionType.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: sessionType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(sessionType.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(sessionType.title)
                    .font(.system(size: 16, weight: .semibold))
                Text("\(duration) • \(time)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Completed badge
            Text("Completed")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(sessionType.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(sessionType.color.opacity(0.1))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    SessionsView()
        .environmentObject(MetricsManager.shared)
}
