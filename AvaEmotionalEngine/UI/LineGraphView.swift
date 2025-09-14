import SwiftUI

struct LineGraphView: View {
    var data: [Double]
    var lineColor: Color = .blue
    var lineWidth: CGFloat = 2.0
    var dotSize: CGFloat = 4.0
    var showDots: Bool = true
    
    private func point(at index: Int, in rect: CGRect) -> CGPoint {
        guard !data.isEmpty, index < data.count else { return .zero }
        
        // Calculate x position based on index
        let xPosition = data.count > 1 ? 
            (CGFloat(index) / CGFloat(data.count - 1)) * rect.width :
            0
        
        // Ensure y-position starts from 0 (bottom of the graph)
        // and scales to the actual data range, but never goes below 0
        let value = max(0, data[index]) // Ensure we don't go below 0
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
                    
                    // Add dots at data points if enabled
                    if showDots {
                        ForEach(0..<data.count, id: \.self) { index in
                            Circle()
                                .fill(lineColor)
                                .frame(width: dotSize, height: dotSize)
                                .position(point(at: index, in: geometry.frame(in: .local)))
                        }
                    }
                }
                
                // Y-axis grid lines without labels
                // Grid lines are kept for visual reference
            }
        }
        .frame(height: 100)
        .padding(.vertical, 8)
    }
}

struct LineGraphView_Previews: PreviewProvider {
    static var previews: some View {
        // Generate sample data with a sine wave pattern
        let sampleData = (0..<24).map { i -> Double in
            return 0.5 + 0.3 * sin(Double(i) * 0.25)
        }
        
        LineGraphView(data: sampleData, lineColor: .blue, showDots: true)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Line Graph Preview")
    }
}
