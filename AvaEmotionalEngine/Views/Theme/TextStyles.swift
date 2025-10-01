import SwiftUI

// MARK: - Custom Text Styles
struct AppTextStyles {
    // Large title style (for main headings)
    static let largeTitle = Font.system(size: 48, weight: .bold, design: .rounded)
    
    // Title style (for section headers)
    static let title = Font.system(size: 40, weight: .bold, design: .rounded)
    
    // Headline style (for important text)
    static let headline = Font.system(size: 34, weight: .semibold, design: .rounded)
    
    // Subheadline style (for secondary text)
    static let subheadline = Font.system(size: 30, weight: .medium, design: .rounded)
    
    // Body style (for regular text)
    static let body = Font.system(size: 28, weight: .regular, design: .rounded)
    
    // Caption style (for captions and footnotes)
    static let caption = Font.system(size: 24, weight: .regular, design: .rounded)
    
    // Small caption style (for very small text)
    static let smallCaption = Font.system(size: 20, weight: .regular, design: .rounded)
}

// MARK: - View Modifiers
struct AppTextStyle: ViewModifier {
    let style: Font
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(style)
            .foregroundColor(color)
    }
}

// MARK: - View Extensions
extension View {
    // Apply large title style
    func largeTitleStyle(color: Color = .primary) -> some View {
        modifier(AppTextStyle(style: AppTextStyles.largeTitle, color: color))
    }
    
    // Apply title style
    func titleStyle(color: Color = .primary) -> some View {
        modifier(AppTextStyle(style: AppTextStyles.title, color: color))
    }
    
    // Apply headline style
    func headlineStyle(color: Color = .primary) -> some View {
        modifier(AppTextStyle(style: AppTextStyles.headline, color: color))
    }
    
    // Apply subheadline style
    func subheadlineStyle(color: Color = .primary) -> some View {
        modifier(AppTextStyle(style: AppTextStyles.subheadline, color: color))
    }
    
    // Apply body style
    func bodyStyle(color: Color = .primary) -> some View {
        modifier(AppTextStyle(style: AppTextStyles.body, color: color))
    }
    
    // Apply caption style
    func captionStyle(color: Color = .primary) -> some View {
        modifier(AppTextStyle(style: AppTextStyles.caption, color: color))
    }
    
    // Apply small caption style
    func smallCaptionStyle(color: Color = .primary) -> some View {
        modifier(AppTextStyle(style: AppTextStyles.smallCaption, color: color))
    }
}
