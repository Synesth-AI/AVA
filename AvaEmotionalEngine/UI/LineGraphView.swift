import SwiftUI

struct LineGraphView: View {
    var data: [(date: Date, value: Double)]
    var lineColor: Color = .blue
    var lineWidth: CGFloat = 2.0
    var dotSize: CGFloat = 4.0
    var showDots: Bool = true
    
    private func point(at index: Int, in rect: CGRect) -> CGPoint {
        guard !data.isEmpty, index < data.count else { return .zero }
        
        let timeRange = data.last!.date.timeIntervalSince(data.first!.date)
        let xPosition = timeRange > 0 ? 
            CGFloat(data[index].date.timeIntervalSince(data.first!.date) / timeRange) * rect.width :
            0
        
        // Ensure y-position starts from 0 (bottom of the graph)
        // and scales to the actual data range, but never goes below 0
        let value = max(0, data[index].value) // Ensure we don't go below 0
        let yPosition = (1 - CGFloat(value)) * rect.height
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid
                Path { path in
                    // Horizontal lines
                    for i in 0...4 {
                        let y = (geometry.size.height / 4) * CGFloat(i)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [2]))
                
                // Line graph
                if data.count >= 2 {
                    Path { path in
                        path.move(to: point(at: 0, in: geometry.frame(in: .local)))
                        
                        for i in 1..<data.count {
                            path.addLine(to: point(at: i, in: geometry.frame(in: .local)))
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    
                    // Dots at data points
                    if showDots {
                        ForEach(0..<data.count, id: \.self) { index in
                            if index % 5 == 0 { // Show every 5th point to avoid clutter
                                Circle()
                                    .fill(lineColor)
                                    .frame(width: dotSize, height: dotSize)
                                    .position(point(at: index, in: geometry.frame(in: .local)))
                            }
                        }
                    }
                }
                
                // Score indicators on the left
                VStack(alignment: .leading, spacing: 0) {
                    // Ensure the max value is at least 1.0 to prevent division by zero
                    let maxValue = max(1.0, data.map { $0.value }.max() ?? 1.0)
                    
                    Text(String(format: "%.0f%%", min(100, maxValue * 100)))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.0f%%", (maxValue * 50)))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("0%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .frame(height: 100)
        .padding(.vertical, 8)
    }
}

struct LineGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let now = Date()
        let sampleData = (0..<60).map { i -> (date: Date, value: Double) in
            let time = now.addingTimeInterval(TimeInterval(-(60 - i) * 60))
            let value = 0.5 + 0.3 * sin(Double(i) * 0.2)
            return (date: time, value: value)
        }
        
        LineGraphView(data: sampleData)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
