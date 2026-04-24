import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isOnboardingComplete {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.isOnboardingComplete)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(AudioPlayerService())
        .environmentObject(TrialService())
        .environmentObject(DownloadService())
}
