import SwiftUI

// MARK: - Text Style Extensions
extension Text {
    func appLargeTitle() -> some View {
        self.font(.system(size: 48, weight: .bold, design: .rounded))
    }
    
    func appTitle() -> some View {
        self.font(.system(size: 40, weight: .bold, design: .rounded))
    }
    
    func appHeadline() -> some View {
        self.font(.system(size: 15, weight: .semibold, design: .rounded))
    }
    
    func appSubheadline() -> some View {
        self.font(.system(size: 30, weight: .medium, design: .rounded))
    }
    
    func appBody() -> some View {
        self.font(.system(size: 20, weight: .regular, design: .rounded))
    }
    
    func appCaption() -> some View {
        self.font(.system(size: 24, weight: .regular, design: .rounded))
    }
    
    func appSmallCaption() -> some View {
        self.font(.system(size: 20, weight: .regular, design: .rounded))
    }
}
