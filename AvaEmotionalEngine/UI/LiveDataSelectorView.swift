import SwiftUI

struct LiveDataSelectorView: View {
    @State private var selectedTab: LiveDataTab = .liveKR

    enum LiveDataTab: String, CaseIterable, Identifiable {
        case liveKR = "Live KR"
        case liveEEG = "Live EEG"

        var id: String { self.rawValue }
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Data", selection: $selectedTab) {
                    ForEach(LiveDataTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                Spacer()

                switch selectedTab {
                case .liveKR:
                    LiveKRView()
                case .liveEEG:
                    LiveEEGStreamView()
                }

                Spacer()
            }
            .navigationTitle("Live Data Selector")
        }
    }
}

struct LiveKRView: View {
    var body: some View {
        Text("Live KR Data Display")
            .font(.title)
            .padding()
    }
}

// EEG Frequency Band
struct EEGBand: Identifiable {
    let id = UUID()
    let name: String
    let frequencyRange: String
    let color: Color
    var data: [Double] = []
}

class EEGViewModel: ObservableObject {
    @Published var bands: [EEGBand]
    @Published var rawEEGData: [Double] = []
    @Published var isConnected: Bool = false
    @Published var connectionStatus: String = "Disconnected"
    
    private let museManager = MuseManager.shared
    private let eegReceiver = MuseEEGReceiver.shared
    private let maxDataPoints = 256 // Muse sample rate is 256Hz, so this gives us 1 second of data
    private var timer: Timer?
    
    init() {
        self.bands = [
            EEGBand(name: "Delta", frequencyRange: "0.5-4 Hz", color: .blue),
            EEGBand(name: "Theta", frequencyRange: "4-8 Hz", color: .green),
            EEGBand(name: "Alpha", frequencyRange: "8-13 Hz", color: .orange),
            EEGBand(name: "Beta", frequencyRange: "13-30 Hz", color: .red),
            EEGBand(name: "Gamma", frequencyRange: "30-100 Hz", color: .purple)
        ]
        
        startUpdates()
    }
    
    func startUpdates() {
        // Start scanning for Muse if not already connected
        if !eegReceiver.isStreaming {
            museManager.startScanning()
        }
        
        // Set up a timer to update the UI with the latest data
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateEEGData()
        }
    }
    
    func updateEEGData() {
        // Get the latest reading from MuseEEGReceiver
        let reading = eegReceiver.latestReading
        
        // Update the connection status
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isConnected = self.eegReceiver.isStreaming
            self.connectionStatus = self.isConnected ? "Connected to Muse" : "Disconnected"
            
            // Update each band's data
            if self.bands.count >= 5 {
                self.bands[0].data.append(reading.delta)
                self.bands[1].data.append(reading.theta)
                self.bands[2].data.append(reading.alpha)
                self.bands[3].data.append(reading.beta)
                self.bands[4].data.append(reading.gamma)
                
                // Update raw EEG data (for combined view)
                let combined = (reading.delta + reading.theta + reading.alpha + reading.beta + reading.gamma) / 5.0
                self.rawEEGData.append(combined)
                
                // Keep data arrays at manageable size
                for i in self.bands.indices {
                    if self.bands[i].data.count > self.maxDataPoints {
                        self.bands[i].data.removeFirst()
                    }
                }
                
                if self.rawEEGData.count > self.maxDataPoints {
                    self.rawEEGData.removeFirst()
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct LiveEEGStreamView: View {
    @StateObject private var viewModel = EEGViewModel()
    @State private var selectedBand: String? = nil // Keep for button highlighting
    @State private var scrollViewContentSize: CGSize = .zero
    @State private var lastUpdate = Date()
    @State private var updateTimer: Timer? = nil
    
    let maxDataPoints = 256 // Muse sample rate is 256Hz, so this gives us 1 second of data
    
    // Define frequency bands with their display names and colors
    private let frequencyBands = [
        (name: "Delta", range: 0.5..<4.0, color: Color.blue),
        (name: "Theta", range: 4.0..<8.0, color: Color.green),
        (name: "Alpha", range: 8.0..<13.0, color: Color.orange),
        (name: "Beta", range: 13.0..<30.0, color: Color.red),
        (name: "Gamma", range: 30.0..<50.0, color: Color.purple)
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Connection Status
            HStack {
                Circle()
                    .fill(viewModel.isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(viewModel.connectionStatus)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                if !viewModel.isConnected {
                    Button("Connect") {
                        // The view model will handle the connection
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top, 4)
            
            // Frequency Band Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // All button to show all bands
                    Button(action: {
                        selectedBand = nil
                    }) {
                        Text("All")
                            .font(.subheadline)
                            .padding(8)
                            .background(selectedBand == nil ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    ForEach(frequencyBands, id: \.name) { band in
                        Button(action: {
                            // Toggle selection (select/deselect)
                            selectedBand = selectedBand == band.name ? nil : band.name
                        }) {
                            Text(band.name)
                                .font(.subheadline)
                                .padding(8)
                                .background(selectedBand == band.name ? band.color.opacity(0.7) : Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 4)
            
            ScrollView(showsIndicators: true) {
                VStack(spacing: 12) {
                    // Add some padding at the top to prevent content from being hidden under the navigation bar
                    Spacer().frame(height: 8)
                    
                    // Show selected band or all bands based on selection
                    if let selectedBand = selectedBand, let band = frequencyBands.first(where: { $0.name == selectedBand }) {
                        BandGraphView(
                            title: "\(band.name) (\(String(format: "%.1f-%.1f Hz", band.range.lowerBound, band.range.upperBound)))",
                            data: viewModel.bands.first(where: { $0.name == band.name })?.data ?? [],
                            color: band.color,
                            maxDataPoints: maxDataPoints,
                            range: band.range,
                            unit: "μV"
                        )
                        .frame(height: 280) // Larger when showing single band
                        .padding(.horizontal)
                    } else {
                        // Show all bands
                        ForEach(frequencyBands, id: \.name) { band in
                            BandGraphView(
                                title: "\(band.name) (\(String(format: "%.1f-%.1f Hz", band.range.lowerBound, band.range.upperBound)))",
                                data: viewModel.bands.first(where: { $0.name == band.name })?.data ?? [],
                                color: band.color,
                                maxDataPoints: maxDataPoints,
                                range: band.range,
                                unit: "μV"
                            )
                            .frame(height: 120)
                            .padding(.horizontal)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(band.color.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            scrollViewContentSize = geometry.size
                        }
                }
            )
        }
        .onAppear {
            // Start a timer to keep the view updating
            updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                viewModel.objectWillChange.send()
            }
        }
        .onDisappear {
            // Invalidate timer when view disappears to prevent memory leaks
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
}

// MARK: - Band Graph View
struct BandGraphView: View {
    let title: String
    let data: [Double]
    let color: Color
    let maxDataPoints: Int
    let range: Range<Double>
    let unit: String
    
    private var normalizedData: [Double] {
        guard !data.isEmpty else { return [] }
        
        // Special handling for Delta waves to make them more visible
        if title.contains("Delta") {
            let adjustedData = data.map { $0 * 2.0 } // Boost delta waves for better visibility
            let maxValue = max(1.0, adjustedData.max() ?? 1.0)
            return adjustedData.map { min($0 / maxValue, 1.0) } // Ensure values stay within 0...1
        }
        
        // Standard normalization for other bands
        let maxValue = max(1.0, data.max() ?? 1.0)
        return data.map { $0 / maxValue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white) // Changed to white for better visibility
                    .opacity(0.9) // Slightly transparent for better contrast
                Spacer()
                if let lastValue = data.last {
                    Text(String(format: "%.1f \(unit)", lastValue))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.white) // Changed to white
                        .opacity(0.9) // Slightly transparent for better contrast
                }
            }
            
            GeometryReader { geometry in
                ZStack {
                    // Grid lines
                    Path { path in
                        // Horizontal lines
                        for i in 0...4 {
                            let y = geometry.size.height * CGFloat(i) / 4
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                    
                    // Waveform
                    if !normalizedData.isEmpty {
                        Path { path in
                            let step = geometry.size.width / CGFloat(normalizedData.count - 1)
                            let baseY = geometry.size.height
                            
                            path.move(to: CGPoint(x: 0, y: baseY * (1 - CGFloat(normalizedData[0]))))
                            
                            for i in 1..<normalizedData.count {
                                let x = step * CGFloat(i)
                                let y = baseY * (1 - CGFloat(normalizedData[i]))
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                }
            }
            .frame(height: 80)
            .background(Color.black.opacity(0.3)) // Darker background for better contrast
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct LiveDataSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        LiveDataSelectorView()
    }
}
