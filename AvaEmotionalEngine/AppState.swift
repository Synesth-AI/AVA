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
        // Load persisted values (do not reset on launch)
        let defaults = UserDefaults.standard
        let persistedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        let persistedDeviceSetup = defaults.bool(forKey: "hasCompletedDeviceSetup")
        let persistedPermissionsSetup = defaults.bool(forKey: "hasCompletedPermissionsSetup")
        let persistedUserName = defaults.string(forKey: "userName") ?? ""

        // Initialize with persisted values
        _isSplashActive = Published(initialValue: true)
        _hasCompletedOnboarding = Published(initialValue: persistedOnboarding)
        _userName = Published(initialValue: persistedUserName)
        _hasCompletedDeviceSetup = Published(initialValue: persistedDeviceSetup)
        _hasCompletedPermissionsSetup = Published(initialValue: persistedPermissionsSetup)
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
