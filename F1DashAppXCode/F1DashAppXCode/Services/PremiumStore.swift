//
//  PremiumStore.swift
//  F1DashAppXCode
//
//  Manages premium subscriptions with RevenueCat and swift-sharing
//

import SwiftUI
import Sharing
import RevenueCat

enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed(String)
    case restoreFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        }
    }
}

@MainActor
@Observable
final class PremiumStore {
    // MARK: - Shared Premium State
    
    @ObservationIgnored
    @Shared(.appStorage("isPremiumUser")) var isPremiumUser = false
    
    @ObservationIgnored
    @Shared(.appStorage("subscriptionType")) var subscriptionType: String = ""
    
    @ObservationIgnored
    @Shared(.appStorage("purchaseExpirationDate")) var purchaseExpirationDate: String = ""
    
    // MARK: - RevenueCat Products
    
    private(set) var monthlyPackage: Package?
    private(set) var annualPackage: Package?
    private(set) var lifetimePackage: Package?
    
    // MARK: - UI State
    
    private(set) var isLoadingProducts = false
    private(set) var purchaseError: String?
    private(set) var isPurchasing = false
    private(set) var isRestoring = false
    
    // MARK: - Initialization
    
    init() {
        // Check premium status on init
        Task {
            await checkPremiumStatus()
            await loadProducts()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load products from RevenueCat
    func loadProducts() async {
        isLoadingProducts = true
        purchaseError = nil
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            if let offering = offerings.current {
                // Find packages by identifier
                for package in offering.availablePackages {
                    switch package.identifier {
                    case "$rc_monthly", "monthly":
                        monthlyPackage = package
                    case "$rc_annual", "annual":
                        annualPackage = package
                    case "lifetime":
                        lifetimePackage = package
                    default:
                        // Also check product identifier
                        if package.storeProduct.productIdentifier.contains("monthly") {
                            monthlyPackage = package
                        } else if package.storeProduct.productIdentifier.contains("annual") {
                            annualPackage = package
                        } else if package.storeProduct.productIdentifier.contains("lifetime") {
                            lifetimePackage = package
                        }
                    }
                }
            }
            
            print("🛍️ Loaded products - Monthly: \(monthlyPackage != nil), Annual: \(annualPackage != nil), Lifetime: \(lifetimePackage != nil)")
        } catch {
            purchaseError = error.localizedDescription
            print("❌ Failed to load products: \(error)")
        }
        
        isLoadingProducts = false
    }
    
    /// Purchase a specific product
    func purchase(_ productId: String) async throws {
        isPurchasing = true
        purchaseError = nil
        
        defer { isPurchasing = false }
        
        let package: Package?
        switch productId {
        case "monthly":
            package = monthlyPackage
        case "annual":
            package = annualPackage
        case "lifetime":
            package = lifetimePackage
        default:
            package = nil
        }
        
        guard let package else {
            throw PurchaseError.productNotFound
        }
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            
            // Update premium status
            updatePremiumStatus(from: result.customerInfo)
            
            // Check if purchase was successful
            if !result.customerInfo.entitlements.active.isEmpty {
                print("✅ Purchase successful!")
            }
        } catch let error as ErrorCode {
            // Handle RevenueCat specific errors
            if error == .purchaseCancelledError {
                // User cancelled, don't show error
                print("🚫 Purchase cancelled by user")
                return
            }
            purchaseError = error.localizedDescription
            throw PurchaseError.purchaseFailed(error.localizedDescription)
        } catch {
            purchaseError = error.localizedDescription
            throw PurchaseError.purchaseFailed(error.localizedDescription)
        }
    }
    
    /// Restore previous purchases
    func restorePurchases() async throws {
        isRestoring = true
        purchaseError = nil
        
        defer { isRestoring = false }
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            updatePremiumStatus(from: customerInfo)
            
            if customerInfo.entitlements.active.isEmpty {
                throw PurchaseError.restoreFailed("No active subscriptions found")
            }
            
            print("✅ Restore successful!")
        } catch {
            purchaseError = error.localizedDescription
            throw error
        }
    }
    
    /// Check current premium status
    func checkPremiumStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updatePremiumStatus(from: customerInfo)
        } catch {
            print("❌ Failed to check premium status: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Update premium status from CustomerInfo
    private func updatePremiumStatus(from customerInfo: CustomerInfo) {
        let hasPremium = !customerInfo.entitlements.active.isEmpty
        
        $isPremiumUser.withLock { $0 = hasPremium }
        
        if let entitlement = customerInfo.entitlements.active["premium"] {
            $subscriptionType.withLock { 
                $0 = entitlement.productIdentifier 
            }
            
            if let expirationDate = entitlement.expirationDate {
                $purchaseExpirationDate.withLock { 
                    $0 = ISO8601DateFormatter().string(from: expirationDate)
                }
            } else {
                // Lifetime purchase has no expiration
                $purchaseExpirationDate.withLock { $0 = "" }
            }
            
            print("🎉 Premium status updated - Active: \(hasPremium), Type: \(entitlement.productIdentifier)")
        } else {
            $subscriptionType.withLock { $0 = "" }
            $purchaseExpirationDate.withLock { $0 = "" }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get display price for a product
    func priceString(for productId: String) -> String {
        let package: Package?
        switch productId {
        case "monthly":
            package = monthlyPackage
        case "annual":
            package = annualPackage
        case "lifetime":
            package = lifetimePackage
        default:
            return "$0.00"
        }
        
        return package?.localizedPriceString ?? "$0.00"
    }
    
    /// Check if products are loaded
    var hasLoadedProducts: Bool {
        monthlyPackage != nil || annualPackage != nil || lifetimePackage != nil
    }
}