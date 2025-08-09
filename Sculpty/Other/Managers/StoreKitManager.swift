//
//  StoreKitManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/7/25.
//

import SwiftUI
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProducts: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = StoreKitManager()
    
    private var transactionListener: Task<Void, Error>?
    
    private init() {
        transactionListener = listenForTransactions()
        
        Task {
            await loadProducts()
            
            await checkPurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    var hasPremiumAccess: Bool {
        purchasedProducts.contains(ProductID.premium.rawValue)
    }
    
    func hasAddOn(_ productID: ProductID) -> Bool {
        purchasedProducts.contains(productID.rawValue)
    }
    
    func product(for productID: ProductID) -> Product? {
        products.first { $0.id == productID.rawValue }
    }
    
    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                purchasedProducts.insert(transaction.productID)
                
                Popup.show(content: {
                    InfoPopup(
                        title: "Upgrade Successful",
                        text: "You have now been upgraded to premium! Thank you for supporting Sculpty!"
                    )
                })
                
                await transaction.finish()
            case .userCancelled:
                errorMessage = "Purchase cancelled by user"
            case .pending:
                errorMessage = "Purchase is pending approval"
            @unknown default:
                errorMessage = "An unknown error occurred"
            }
        } catch StoreKitError.notAvailableInStorefront {
            errorMessage = "This product is not available in your region"
        } catch StoreKitError.notEntitled {
            errorMessage = "You are not entitled to this product"
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            
            await checkPurchasedProducts()
            
            if !purchasedProducts.isEmpty {
                Popup.show(content: {
                    InfoPopup(
                        title: "Purchases Restored",
                        text: "Your purchases have been restored."
                    )
                })
            } else {
                Popup.show(content: {
                    InfoPopup(
                        title: "No Purchases Restored",
                        text: "No previous purchases were found."
                    )
                })
            }
        } catch {
            errorMessage = "Failed to restore purchases"
        }
        
        isLoading = false
    }
    
    private func loadProducts() async {
        do {
            let productIds = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIds)
        } catch {
            errorMessage = "Failed to load products"
        }
    }
    
    private func checkPurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productType == .nonConsumable ||
                   (transaction.productType == .autoRenewable && !transaction.isUpgraded) {
                    purchased.insert(transaction.productID)
                }
            } catch {
                debugLog("Failed to verify transaction: \(error)")
            }
        }
        
        purchasedProducts = purchased
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { break }
                
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    _ = await MainActor.run { [weak self] in
                        self?.purchasedProducts.insert(transaction.productID)
                    }
                    
                    await transaction.finish()
                } catch {
                    debugLog("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(
                domain: "StoreKitVerification",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Transaction verification failed"]
            )
        case .verified(let safe):
            return safe
        }
    }
    
    var canPerformNutritionSearch: Bool {
        if hasPremiumAccess { return true }
        
        return CloudSettings.shared.weeklyNutritionSearches < maxWeeklyNutritionSearches
    }
    
    var canPerformBarcodeScans: Bool {
        if hasPremiumAccess { return true }
        
        return CloudSettings.shared.weeklyBarcodeScans < maxWeeklyBarcodeScans
    }
}
