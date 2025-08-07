import SwiftUI

// Helper extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    @EnvironmentObject var appState: AppState
    @State private var nameInput: String = ""
    @State private var showNameError = false
    @State private var hasAgreedToTerms = false
    
    // Onboarding pages data
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to AVA",
            subtitle: "Your AI companion for emotional well-being and self-discovery.",
            imageName: "onboarding1",
            showButton: false
        ),
        OnboardingPage(
            title: "Smart Interventions",
            subtitle: "Track focus, mood, and mental energy—powered by your brainwaves.",
            imageName: "onboarding2",
            showButton: false
        ),
        OnboardingPage(
            title: "Get Started",
            subtitle: "Begin your journey to better emotional health with AVA.",
            imageName: "onboarding3",
            showButton: true
        )
    ]
    
    var body: some View {
        ZStack {
            // Background (matching splash screen)
            Color.white.edgesIgnoringSafeArea(.all)
            
            // Gradient circles (matching splash screen)
            ZStack {
                // First gradient circle (pink)
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 337, height: 337)
                    .background(Color(red: 0.88, green: 0.44, blue: 0.56))
                    .cornerRadius(337)
                    .blur(radius: 50)
                    .offset(x: -111, y: 536)  // Position at (-111, 536)
                
                // Second gradient circle (blue)
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 337, height: 337)
                    .background(Color(red: 0.4, green: 0.76, blue: 0.86))
                    .cornerRadius(337)
                    .blur(radius: 50)
                    .offset(x: 226, y: 561)  // Position at (226, 561)
            }
            .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 0) {
                // Skip button (only show on first two pages)
                if currentPage < pages.count - 1 {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                appState.hasCompletedOnboarding = true
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                                .padding()
                        }
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], currentPage: currentPage)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Spacer()
                
                // Name input field (only on last screen)
                if currentPage == pages.count - 1 {
                    VStack(spacing: 8) {
                        Text("What's your name?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 40)
                        
                        TextField("Your name", text: $nameInput)
                            .onChange(of: nameInput) { newValue in
                                // Only allow letters and spaces, with a max length of 30 characters
                                let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                                if filtered != newValue {
                                    nameInput = filtered
                                }
                                // Limit to 30 characters
                                if nameInput.count > 30 {
                                    nameInput = String(nameInput.prefix(30))
                                }
                                // Update appState when valid
                                if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                    appState.userName = nameInput.trimmingCharacters(in: .whitespaces)
                                }
                                showNameError = nameInput.trimmingCharacters(in: .whitespaces).isEmpty
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 8)
                        
                        if showNameError {
                            Text("Please enter a valid name")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 12)
                        } else {
                            // Empty view to maintain consistent spacing
                            Text("")
                                .frame(height: 20)
                                .padding(.bottom, 12)
                        }
                    }
                }
                
                // Page indicator
                PageControl(numberOfPages: pages.count, currentPage: $currentPage)
                    .padding(.bottom, 30)  // Increased from 20 to 30
                
                // Next/Get Started button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        // Validate name and terms agreement on last screen before proceeding
                        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
                        if trimmedName.isEmpty {
                            showNameError = true
                        } else if !hasAgreedToTerms {
                            // Show error for terms not agreed
                            showNameError = false
                        } else {
                            appState.userName = trimmedName
                            withAnimation {
                                appState.hasCompletedOnboarding = true
                            }
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2E69C3"))
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    
                    // Privacy terms checkbox (only on last screen)
                    if currentPage == pages.count - 1 {
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    hasAgreedToTerms.toggle()
                                }
                            }) {
                                Image(systemName: hasAgreedToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(hasAgreedToTerms ? Color(hex: "#2E69C3") : .gray)
                                    .font(.system(size: 20))
                            }
                            
                            HStack(spacing: 4) {
                                Text("I agree to the")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                                
                                Button(action: {
                                    // TODO: Show privacy policy
                                }) {
                                    Text("Privacy Policy")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#2E69C3"))
                                }
                                
                                Text("and")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                                
                                Button(action: {
                                    // TODO: Show terms of service
                                }) {
                                    Text("Terms of Service")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#2E69C3"))
                                }
                            }
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 10)
                    } else {
                        Spacer()
                            .frame(height: 30)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let showButton: Bool
}

struct OnboardingPageView: View {
    @EnvironmentObject var appState: AppState
    let page: OnboardingPage
    let currentPage: Int
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Logo at the top (shown on all screens)
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            // Main content area with consistent layout
            VStack(spacing: 0) {
                // For first screen, show the image in the content area
                if currentPage == 0 {
                    Image("Onboarding1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 500, maxHeight: 500)
                        .padding(.top, 0)
                        .padding(.bottom, 24)
                }
                
                // Title and Subtitle - consistent across all screens
                VStack(spacing: 16) {
                    Text(page.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text(page.subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 0.27, green: 0.33, blue: 0.36).opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .frame(maxHeight: .infinity, alignment: .center) // Centered for all screens
                
                // Spacer to push content up if needed
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

struct PageControl: View {
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color(red: 0.88, green: 0.44, blue: 0.56) : Color.gray.opacity(0.3))
                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                    .animation(.easeInOut, value: currentPage)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppState())
    }
}
