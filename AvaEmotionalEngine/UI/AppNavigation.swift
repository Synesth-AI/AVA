import SwiftUI

// Navigation wrapper for the app
struct AppNavigation: View {
    var body: some View {
        NavigationView {
            HomeView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct AppNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppNavigation()
            .environmentObject(AppState())
            .environmentObject(MetricsManager.shared)
    }
}
#endif
