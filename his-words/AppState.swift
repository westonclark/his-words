import SwiftUI

final class AppState: ObservableObject {
    @Published var isOnboardingComplete: Bool
    @Published var showPaywall = false

    init() {
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboardingComplete")
    }

    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
    }
}
