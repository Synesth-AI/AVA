import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isSplashActive: Bool
    @Published var hasCompletedOnboarding: Bool
    @Published var userName: String
    @Published var hasCompletedDeviceSetup: Bool
    @Published var hasCompletedPermissionsSetup: Bool
    @Published var isLogoAnimating: Bool
    
    // Property observers for UserDefaults persistence
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Reset all onboarding states on every launch
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasCompletedDeviceSetup")
        UserDefaults.standard.set(false, forKey: "hasCompletedPermissionsSetup")
        UserDefaults.standard.set("", forKey: "userName")
        
        // Initialize with default values (onboarding not completed)
        _isSplashActive = Published(initialValue: true)
        _hasCompletedOnboarding = Published(initialValue: false)
        _userName = Published(initialValue: "")
        _hasCompletedDeviceSetup = Published(initialValue: false)
        _hasCompletedPermissionsSetup = Published(initialValue: false)
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
            
        $hasCompletedPermissionsSetup
            .dropFirst()
            .sink { [weak self] value in
                guard let self = self else { return }
                UserDefaults.standard.set(value, forKey: "hasCompletedPermissionsSetup")
            }
            .store(in: &cancellables)
    }
    
    func finishSplash() {
        // The animation will be handled in the view where this state is observed
        isSplashActive = false
    }
}
