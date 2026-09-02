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
                    trial.observe(audio)
                    trial.observeSubscriptionStatus(from: storeKit)
                }
                .preferredColorScheme(.dark)
        }
    }
}
