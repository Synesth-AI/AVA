import SwiftUI

// Tab enum for navigation
enum Tab: String, CaseIterable, Identifiable {
    case home = "house"
    case sessions = "timer"
    case journal = "book.closed"
    case sync = "arrow.2.circlepath"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .sessions: return "Sessions"
        case .journal: return "Journal"
        case .sync: return "Sync"
        }
    }
}

#if DEBUG
extension Tab {
    static var preview: Tab {
        .home
    }
}
#endif
