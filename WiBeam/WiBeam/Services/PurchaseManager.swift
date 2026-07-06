import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published private(set) var isPro: Bool = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastError: String?

    private var transactionListener: Task<Void, Never>?

    static let monthlyID = "com.zzoutuo.WiBeam.pro.monthly"
    static let annualID = "com.zzoutuo.WiBeam.pro.annual"
    static let lifetimeID = "com.zzoutuo.WiBeam.lifetime"
    static let allProductIDs: Set<String> = [monthlyID, annualID, lifetimeID]

    private init() {
        transactionListener = listenForTransactions()

        Task {
            await loadProducts()
            await updatePurchasedStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: PurchaseManager.allProductIDs)
            self.products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerification(verification)
            await updatePurchasedStatus()
            await transaction.finish()
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedStatus()
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.updatePurchasedStatus()
                }
            }
        }
    }

    private func updatePurchasedStatus() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }

        self.purchasedProductIDs = purchased
        self.isPro = !purchased.isEmpty
    }

    private func checkVerification<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw error
        }
    }
}
