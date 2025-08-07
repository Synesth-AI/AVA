import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isSplashActive: Bool
    @Published var hasCompletedOnboarding: Bool
    @Published var userName: String
    @Published var hasCompletedDeviceSetup: Bool
    @Published var isLogoAnimating: Bool
    
    // Property observers for UserDefaults persistence
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check if this is the first launch after install/clean build
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            // Reset all onboarding states for first launch
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            UserDefaults.standard.set(false, forKey: "hasCompletedDeviceSetup")
            UserDefaults.standard.set("", forKey: "userName")
        }
        
        // Initialize with values from UserDefaults
        _isSplashActive = Published(initialValue: true)
        _hasCompletedOnboarding = Published(initialValue: UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))
        _userName = Published(initialValue: UserDefaults.standard.string(forKey: "userName") ?? "")
        _hasCompletedDeviceSetup = Published(initialValue: UserDefaults.standard.bool(forKey: "hasCompletedDeviceSetup"))
        _isLogoAnimating = Published(initialValue: false)
        
        // Set up property observers
        $hasCompletedOnboarding
            .dropFirst()
            .sink { [weak self] value in
                guard let self = self else { return }
                UserDefaults.standard.set(value, forKey: "hasCompletedOnboarding")
            }
            .store(in: &cancellables)
            
        $userName
            .dropFirst()
            .sink { [weak self] value in
                guard let self = self else { return }
                UserDefaults.standard.set(value, forKey: "userName")
            }
            .store(in: &cancellables)
            
        $hasCompletedDeviceSetup
            .dropFirst()
            .sink { [weak self] value in
                guard let self = self else { return }
                UserDefaults.standard.set(value, forKey: "hasCompletedDeviceSetup")
            }
            .store(in: &cancellables)
    }
    
    func finishSplash() {
        // The animation will be handled in the view where this state is observed
        isSplashActive = false
    }
}
