import SwiftUI

// MARK: - Custom Text Sizes
struct LargeTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .bold, design: .rounded))
    }
}

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .bold, design: .rounded))
    }
}

struct Headline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 26, weight: .semibold, design: .rounded))
    }
}

struct Subheadline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .medium, design: .rounded))
    }
}

struct BodyText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .regular, design: .rounded))
    }
}

struct CaptionText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular, design: .rounded))
    }
}

// MARK: - View Extensions
extension View {
    func largeTitle() -> some View {
        modifier(LargeTitle())
    }
    
    func title() -> some View {
        modifier(Title())
    }
    
    func headline() -> some View {
        modifier(Headline())
    }
    
    func subheadline() -> some View {
        modifier(Subheadline())
    }
    
    func bodyText() -> some View {
        modifier(BodyText())
    }
    
    func captionText() -> some View {
        modifier(CaptionText())
    }
}
