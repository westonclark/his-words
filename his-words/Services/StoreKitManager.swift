import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false

    private var updateListenerTask: Task<Void, Never>? = nil

    private let productIDs = ["com.hiswords.monthly", "com.hiswords.annual"]

    init() {
        updateListenerTask = watchForTransactionUpdates()
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.id < $1.id }
        } catch {
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchaseStatus()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    private func watchForTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                let transaction = try? checkVerified(result)
                await self.updatePurchaseStatus()
                await transaction?.finish()
            }
        }
    }

    func updatePurchaseStatus() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            let transaction = try? checkVerified(result)
            if let transaction = transaction {
                purchasedIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchasedIDs
    }

    func isSubscribed() async -> Bool {
        await updatePurchaseStatus()
        return !purchasedProductIDs.isEmpty
    }
}
