import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var trial: TrialService
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var storeKit: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: Plan = .annual
    @State private var isPurchasing = false

    enum Plan { case monthly, annual }

    var body: some View {
        ZStack {
            Color.warmBlack.ignoresSafeArea()

            VStack(spacing: 0) {
                dragHandle

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        heading

                        perks

                        planPicker

                        subscribeButton

                        restoreButton

                        legalText
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
    }

    // MARK: – Subviews

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.creamWhite.opacity(0.25))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 20)
    }

    private var heading: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.charcoal)
                    .frame(width: 80, height: 80)
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(.mutedGold)
            }

            Text("Unlock Full Access")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.creamWhite)

            Text("Unlimited nature sounds, every day.")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.mutedCream)
                .multilineTextAlignment(.center)
        }
    }

    private var perks: some View {
        VStack(spacing: 12) {
            PerkRow(icon: "infinity",        text: "Unlimited listening time")
            PerkRow(icon: "lock.open.fill",  text: "All premium playlists")
            PerkRow(icon: "icloud.fill",     text: "Syncs across all your devices")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color.darkCharcoal)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var planPicker: some View {
        HStack(spacing: 12) {
            PlanCard(
                title: "Monthly",
                price: monthlyProduct?.displayPrice ?? "$17.99",
                period: "per month",
                badge: nil,
                isSelected: selectedPlan == .monthly
            ) { selectedPlan = .monthly }

            PlanCard(
                title: "Annual",
                price: annualProduct?.displayPrice ?? "$119.99",
                period: "per year",
                badge: annualSavingsBadge,
                isSelected: selectedPlan == .annual
            ) { selectedPlan = .annual }
        }
    }

    private var monthlyProduct: Product? {
        storeKit.products.first(where: { $0.id == "com.hiswords.monthly" })
    }

    private var annualProduct: Product? {
        storeKit.products.first(where: { $0.id == "com.hiswords.annual" })
    }

    private var annualSavingsBadge: String? {
        guard let monthly = monthlyProduct, let annual = annualProduct else { return "SAVE 44%" }
        let yearlyAtMonthlyRate = monthly.price * 12
        guard yearlyAtMonthlyRate > 0 else { return nil }
        let savings = NSDecimalNumber(decimal: (yearlyAtMonthlyRate - annual.price) / yearlyAtMonthlyRate).doubleValue
        let percent = Int((savings * 100).rounded())
        return percent > 0 ? "SAVE \(percent)%" : nil
    }

    private var subscribeCaption: String {
        if selectedPlan == .annual {
            let price = annualProduct?.displayPrice ?? "$119.99"
            return "\(price)/year, billed annually"
        } else {
            let price = monthlyProduct?.displayPrice ?? "$17.99"
            return "\(price)/month, cancel anytime"
        }
    }

    private var subscribeButton: some View {
        Button {
            isPurchasing = true
            Task {
                let productID = selectedPlan == .annual ? "com.hiswords.annual" : "com.hiswords.monthly"
                if let product = storeKit.products.first(where: { $0.id == productID }) {
                    let success = await storeKit.purchase(product)
                    if success {
                        trial.grantSubscription()
                        appState.showPaywall = false
                        dismiss()
                    }
                }
                isPurchasing = false
            }
        } label: {
            VStack(spacing: 2) {
                Text(selectedPlan == .annual ? "Subscribe Annually" : "Subscribe Monthly")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.warmBlack)
                Text(subscribeCaption)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.warmBlack.opacity(0.65))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isPurchasing ? Color.mutedGold.opacity(0.7) : Color.mutedGold)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(storeKit.isLoading || isPurchasing || storeKit.products.isEmpty)
    }

    private var restoreButton: some View {
        Button {
            Task {
                await storeKit.restorePurchases()
                trial.syncSubscriptionStatus(from: storeKit)
                if trial.isSubscribed {
                    appState.showPaywall = false
                    dismiss()
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.mutedCream)
        }
    }

    private var legalText: some View {
        VStack(spacing: 8) {
            Text("Subscription auto-renews unless cancelled at least 24 hours before the end of the period. Manage in App Store settings.")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.mutedCream.opacity(0.6))
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Text("·")
                Link("Privacy Policy", destination: URL(string: "https://westonclark.github.io/his-words/privacy.html")!)
            }
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.mutedCream.opacity(0.75))
        }
    }
}

// MARK: – Helper views

private struct PerkRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.mutedGold)
                .font(.system(size: 16))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.creamWhite)
            Spacer()
        }
    }
}

private struct PlanCard: View {
    let title: String
    let price: String
    let period: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .mutedGold : .mutedCream)
                    Text(price)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.creamWhite)
                    Text(period)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.mutedCream)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isSelected ? Color.charcoal : Color.darkCharcoal)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.mutedGold : Color.clear, lineWidth: 1.5)
                )

                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.warmBlack)
                        .tracking(0.8)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.mutedGold)
                        .clipShape(Capsule())
                        .offset(x: -8, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
