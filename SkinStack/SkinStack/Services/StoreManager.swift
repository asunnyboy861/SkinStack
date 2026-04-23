import Foundation
import StoreKit

@Observable
final class StoreManager {
    var isPro: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    
    private var product: Product?
    private var transactionListener: Task<Void, Never>?
    
    static let proProductID = "com.zzoutuo.SkinStack.pro"
    
    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProduct()
            await checkPurchased()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func purchasePro() async {
        guard let product = product else {
            errorMessage = "Product not available"
            return
        }
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPro = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval"
            @unknown default:
                errorMessage = "Unknown purchase result"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func loadProduct() async {
        do {
            let storeProducts = try await Product.products(for: [Self.proProductID])
            product = storeProducts.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func checkPurchased() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.proProductID {
                    isPro = transaction.revocationDate == nil
                    return
                }
            }
        }
        isPro = false
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == Self.proProductID {
                        await MainActor.run {
                            [weak self] in
                            self?.isPro = transaction.revocationDate == nil
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    enum StoreError: Error {
        case failedVerification
    }
}
