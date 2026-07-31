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
        lastError = nil
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: PurchaseManager.allProductIDs)
            self.products = storeProducts.sorted { $0.price < $1.price }

            if storeProducts.isEmpty {
                self.lastError = "No products available. Please try again later."
            }
        } catch {
            self.lastError = "Could not load subscription plans. Please check your internet connection and try again."
        }
    }

    enum PurchaseResult {
        case success
        case cancelled
        case pending
        case failed(String)
    }

    func purchase(_ product: Product) async -> PurchaseResult {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerification(verification)
                await updatePurchasedStatus()
                await transaction.finish()
                return .success

            case .userCancelled:
                return .cancelled

            case .pending:
                return .pending

            @unknown default:
                return .failed("An unexpected error occurred. Please try again.")
            }
        } catch {
            return .failed(userFriendlyError(error))
        }
    }

    func restorePurchases() async -> String {
        do {
            try await AppStore.sync()
            await updatePurchasedStatus()

            if isPro {
                return "Pro features unlocked! Thank you."
            } else {
                return "No previous purchases found for this Apple ID."
            }
        } catch {
            return "Could not restore purchases. Please check your internet connection and try again."
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

    private func userFriendlyError(_ error: Error) -> String {
        if let storeKitError = error as? StoreKitError {
            switch storeKitError {
            case .userCancelled:
                return "Purchase was cancelled."
            case .networkError:
                return "Could not connect to the App Store. Please check your internet connection and try again."
            case .systemError:
                return "The App Store is temporarily unavailable. Please try again later."
            case .notAvailableInStorefront:
                return "This product is not available in your region."
            case .notEntitled:
                return "You are not authorized to make this purchase. Please sign in to the App Store."
            @unknown default:
                return "An unexpected error occurred. Please try again."
            }
        }
        return "Could not complete purchase. Please try again or contact support."
    }
}
