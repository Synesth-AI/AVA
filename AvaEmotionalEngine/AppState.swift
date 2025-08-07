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
        // Initialize with default values
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
