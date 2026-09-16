import Foundation
import StoreKit
import Combine

@MainActor
final class StoreService: ObservableObject {
    static let shared = StoreService()

    static let proMonthly = "com.zzoutuo.Sketcho.pro.monthly"
    static let proYearly = "com.zzoutuo.Sketcho.pro.yearly"
    static let proLifetime = "com.zzoutuo.Sketcho.pro.lifetime"
    static let studioMonthly = "com.zzoutuo.Sketcho.studio.monthly"
    static let studioYearly = "com.zzoutuo.Sketcho.studio.yearly"
    static let allIds = [proMonthly, proYearly, proLifetime, studioMonthly, studioYearly]

    @Published var isPro: Bool = false
    @Published var isStudio: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var loadError: String?

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await checkEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: Self.allIds)
                .sorted { displayPriceSortRank($0, $1) }
            loadError = nil
        } catch {
            loadError = "Unable to load purchase options."
        }
        isLoading = false
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await checkEntitlements()
                    return true
                }
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            loadError = "Purchase failed: \(error.localizedDescription)"
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkEntitlements()
            loadError = nil
        } catch {
            loadError = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func checkEntitlements() async {
        var pro = false
        var studio = false
        for id in [Self.proMonthly, Self.proYearly, Self.proLifetime] {
            if let entitlement = await Transaction.currentEntitlement(for: id),
               case .verified(let transaction) = entitlement,
               transaction.revocationDate == nil {
                pro = true
            }
        }
        for id in [Self.studioMonthly, Self.studioYearly] {
            if let entitlement = await Transaction.currentEntitlement(for: id),
               case .verified(let transaction) = entitlement,
               transaction.revocationDate == nil {
                studio = true
            }
        }
        isPro = pro || studio
        isStudio = studio
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    Task { @MainActor [weak self] in
                        await self?.checkEntitlements()
                    }
                }
            }
        }
    }
}

private func displayPriceSortRank(_ lhs: Product, _ rhs: Product) -> Bool {
    let order: [String: Int] = [
        StoreService.proMonthly: 0,
        StoreService.proYearly: 1,
        StoreService.proLifetime: 2,
        StoreService.studioMonthly: 3,
        StoreService.studioYearly: 4
    ]
    return (order[lhs.id] ?? 99) < (order[rhs.id] ?? 99)
}
