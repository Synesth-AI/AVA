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
    
    let maxDataPoints = 256 // Muse sample rate is 256Hz, so this gives us 1 second of data
    
    var body: some View {
        VStack {
            // Connection Status
            HStack {
                Circle()
                    .fill(viewModel.isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(viewModel.connectionStatus)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !viewModel.isConnected {
                    Button("Connect") {
                        // The view model will handle the connection
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top)
            
            ScrollView {
            VStack(spacing: 20) {
                Text("EEG Frequency Bands")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Combined waveform
                VStack(alignment: .leading) {
                    Text("Combined Signal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    GeometryReader { geometry in
                        ZStack {
                            // Grid background
                            Path { path in
                                // Horizontal lines
                                for i in 0...4 {
                                    let y = geometry.size.height * CGFloat(i) / 4
                                    path.move(to: CGPoint(x: 0, y: y))
                                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                                }
                                // Vertical lines (time markers)
                                for i in 0..<5 {
                                    let x = geometry.size.width * CGFloat(i) / 4
                                    path.move(to: CGPoint(x: x, y: 0))
                                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                                }
                            }
                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            
                            // Combined waveform
                            if !viewModel.rawEEGData.isEmpty {
                                Path { path in
                                    let width = geometry.size.width
                                    let height = geometry.size.height
                                    let step = width / CGFloat(viewModel.rawEEGData.count - 1)
                                    
                                    path.move(to: CGPoint(x: 0, y: height / 2))
                                    
                                    for index in 1..<viewModel.rawEEGData.count {
                                        let x = step * CGFloat(index)
                                        // Scale the data to fit the view better
                                        let y = height / 2 - CGFloat(viewModel.rawEEGData[index]) * 10.0
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                                .stroke(Color.primary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                            }
                        }
                    }
                    .frame(height: 100)
                    .padding(.horizontal)
                }
                
                // Individual frequency bands
                ForEach($viewModel.bands) { $band in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(band.name)
                                .font(.subheadline)
                                .foregroundColor(band.color)
                            Text(band.frequencyRange)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1f μV", band.data.last ?? 0))
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        
                        GeometryReader { geometry in
                            ZStack {
                                // Grid background
                                Path { path in
                                    // Center line
                                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                                }
                                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                                
                                // Waveform
                                if !band.data.isEmpty {
                                    Path { path in
                                        let width = geometry.size.width
                                        let height = geometry.size.height
                                        let step = width / CGFloat(band.data.count - 1)
                                        
                                        path.move(to: CGPoint(x: 0, y: height / 2))
                                        
                                        for index in 1..<band.data.count {
                                            let x = step * CGFloat(index)
                                            let y = height / 2 - CGFloat(band.data[index]) * (height / 100.0)
                                            path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                    .stroke(band.color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                                }
                            }
                        }
                        .frame(height: 60)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("EEG Monitor")
        .onAppear {
            // ViewModel handles the setup in init
        }
    }
}

struct LiveDataSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        LiveDataSelectorView()
    }
}
