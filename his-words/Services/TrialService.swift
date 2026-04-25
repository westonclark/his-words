import Foundation
import Combine

@MainActor
final class TrialService: ObservableObject {
    static let freeLimit: TimeInterval = 10 * 60  // 10 minutes lifetime free trial

    @Published var isSubscribed: Bool = false

    var remainingFreeSeconds: TimeInterval {
        max(0, Self.freeLimit - usedSeconds)
    }

    var hasExhaustedTrial: Bool {
        !isSubscribed && usedSeconds >= Self.freeLimit
    }

    // Lifetime seconds listened — persisted in UserDefaults, never resets.
    @Published private(set) var usedSeconds: TimeInterval = 0

    private var cancellable: AnyCancellable?
    private var previousAudioTotal: TimeInterval = 0

    private static let secondsKey = "trial_seconds_used"
    private static let subscriptionKey = "subscription_status"

    init() {
        usedSeconds = UserDefaults.standard.double(forKey: Self.secondsKey)
        isSubscribed = UserDefaults.standard.bool(forKey: Self.subscriptionKey)
    }

    func observe(_ audioService: AudioPlayerService) {
        previousAudioTotal = audioService.sessionSeconds
        cancellable = audioService.$sessionSeconds
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] total in
                guard let self else { return }
                let increment = total - self.previousAudioTotal
                if increment > 0 {
                    self.usedSeconds += increment
                    UserDefaults.standard.set(self.usedSeconds, forKey: Self.secondsKey)
                }
                self.previousAudioTotal = total
            }
    }

    // Called after StoreKit purchase confirms entitlement.
    func grantSubscription() {
        isSubscribed = true
        UserDefaults.standard.set(true, forKey: Self.subscriptionKey)
    }

    // Sync subscription status from StoreKit entitlements.
    @MainActor
    func syncSubscriptionStatus(from storeKit: StoreKitManager) {
        let hasEntitlement = !storeKit.purchasedProductIDs.isEmpty
        if hasEntitlement {
            isSubscribed = true
            UserDefaults.standard.set(true, forKey: Self.subscriptionKey)
        } else {
        }
    }

}
