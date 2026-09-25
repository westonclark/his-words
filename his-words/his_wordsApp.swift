import SwiftUI

@main
struct his_wordsApp: App {
    @StateObject private var appState  = AppState()
    @StateObject private var audio     = AudioPlayerService()
    @StateObject private var trial     = TrialService()
    @StateObject private var downloads = DownloadService()
    @StateObject private var storeKit  = StoreKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(audio)
                .environmentObject(trial)
                .environmentObject(downloads)
                .environmentObject(storeKit)
                .onAppear {
                    audio.localURLProvider = { [weak downloads] track in
                        downloads?.localURL(for: track)
                    }
                    audio.isPlaybackAllowed = { [weak trial] in
                        !(trial?.hasExhaustedTrial ?? false)
                    }
                    audio.onPlaybackBlocked = { [weak appState] in
                        appState?.showPaywall = true
                    }
                    trial.observe(audio)
                    trial.observeSubscriptionStatus(from: storeKit)
                }
                .preferredColorScheme(.dark)
        }
    }
}
