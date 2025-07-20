# RevenueCat Implementation Plan

## Overview
This document outlines the implementation of RevenueCat for the F1 Dash app's premium features. Currently, only the WindMapCard feature will be gated behind the premium subscription.

## Architecture Decision
- **RevenueCat** for purchase management (simpler than direct StoreKit)
- **swift-sharing** for persistent premium state
- **No authentication required** - Apple ID handles everything

## Implementation Plan

### 1. Create PremiumStore with Swift-Sharing

**File: Services/PremiumStore.swift**
```swift
import SwiftUI
import Sharing
import RevenueCat

@MainActor
@Observable
final class PremiumStore {
    // Shared premium state using swift-sharing
    @ObservationIgnored
    @Shared(.appStorage("isPremiumUser")) var isPremiumUser = false
    
    @ObservationIgnored
    @Shared(.appStorage("subscriptionType")) var subscriptionType: String = ""
    
    @ObservationIgnored
    @Shared(.appStorage("purchaseExpirationDate")) var purchaseExpirationDate: String = ""
    
    // RevenueCat products
    var monthlyPackage: Package?
    var annualPackage: Package?
    var lifetimePackage: Package?
    
    // Loading states
    var isLoadingProducts = false
    var purchaseError: String?
    var isPurchasing = false
    
    // Initialize and load products
    func loadProducts() async { }
    
    // Purchase specific package
    func purchase(_ productId: String) async throws { }
    
    // Restore purchases
    func restorePurchases() async throws { }
    
    // Check subscription status
    private func updatePremiumStatus() { }
}
```

### 2. Initialize RevenueCat in App

**File: F1DashAppXCodeApp.swift**
```swift
import RevenueCat

@main
struct F1DashAppXCodeApp: App {
    @State private var premiumStore = PremiumStore()
    
    init() {
        // Configure RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "YOUR_REVENUECAT_API_KEY")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(premiumStore)
        }
    }
}
```

### 3. Update PaywallMarqueeView

**Changes needed:**
- Import PremiumStore from environment
- Connect purchase buttons to real RevenueCat purchases
- Show loading spinner during purchase
- Handle purchase errors gracefully
- Add success animation/haptic feedback

```swift
struct PaywallMarqueeView: View {
    @Environment(PremiumStore.self) private var premiumStore
    
    // In button action:
    Button {
        if showSubscriptionOptions && selectedPlan != nil {
            Task {
                await premiumStore.purchase(selectedPlan!)
            }
        }
    }
}
```

### 4. Add Premium Lock to WindMapCard

**Create: Views/PremiumLockOverlay.swift**
```swift
struct PremiumLockOverlay: View {
    let onUnlockTapped: () -> Void
    
    var body: some View {
        ZStack {
            // Blur background
            Rectangle()
                .fill(.ultraThinMaterial)
            
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                Text("Premium Feature")
                    .font(.headline)
                
                Button("Unlock Premium") {
                    onUnlockTapped()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
```

**Update: WindMapCard.swift**
```swift
struct WindMapCard: View {
    @Environment(PremiumStore.self) private var premiumStore
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            // Existing map content
            
            if !premiumStore.isPremiumUser {
                PremiumLockOverlay {
                    showPaywall = true
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallMarqueeView()
        }
    }
}
```

### 5. Product Configuration

**App Store Connect Products:**
- `com.f1dash.premium.monthly` - Monthly Subscription ($0.99)
- `com.f1dash.premium.annual` - Annual Subscription ($2.99)  
- `com.f1dash.premium.lifetime` - Non-Consumable ($4.99)

**RevenueCat Dashboard Setup:**
1. Create "premium" entitlement
2. Map all three products to this entitlement
3. Configure product identifiers
4. Set up webhook endpoints (optional)

### 6. Testing Configuration

**Create: F1DashProducts.storekit**
```json
{
  "products": [
    {
      "id": "com.f1dash.premium.monthly",
      "type": "autoRenewable",
      "price": 0.99,
      "subscriptionPeriod": "P1M"
    },
    {
      "id": "com.f1dash.premium.annual",
      "type": "autoRenewable", 
      "price": 2.99,
      "subscriptionPeriod": "P1Y"
    },
    {
      "id": "com.f1dash.premium.lifetime",
      "type": "nonConsumable",
      "price": 4.99
    }
  ]
}
```

### 7. Implementation Details

#### PremiumStore Methods:

```swift
// Load products from RevenueCat
func loadProducts() async {
    isLoadingProducts = true
    
    do {
        let offerings = try await Purchases.shared.offerings()
        
        if let offering = offerings.current {
            monthlyPackage = offering.package(identifier: "monthly")
            annualPackage = offering.package(identifier: "annual")
            lifetimePackage = offering.package(identifier: "lifetime")
        }
    } catch {
        purchaseError = error.localizedDescription
    }
    
    isLoadingProducts = false
}

// Purchase specific package
func purchase(_ productId: String) async throws {
    isPurchasing = true
    purchaseError = nil
    
    let package: Package?
    switch productId {
    case "monthly": package = monthlyPackage
    case "annual": package = annualPackage
    case "lifetime": package = lifetimePackage
    default: package = nil
    }
    
    guard let package else {
        throw PurchaseError.productNotFound
    }
    
    do {
        let result = try await Purchases.shared.purchase(package: package)
        updatePremiumStatus(from: result.customerInfo)
    } catch {
        purchaseError = error.localizedDescription
        throw error
    }
    
    isPurchasing = false
}

// Update premium status from CustomerInfo
private func updatePremiumStatus(from customerInfo: CustomerInfo) {
    $isPremiumUser.withLock { 
        $0 = !customerInfo.entitlements.active.isEmpty 
    }
    
    if let entitlement = customerInfo.entitlements.active["premium"] {
        $subscriptionType.withLock { 
            $0 = entitlement.productIdentifier 
        }
        
        if let expirationDate = entitlement.expirationDate {
            $purchaseExpirationDate.withLock { 
                $0 = ISO8601DateFormatter().string(from: expirationDate)
            }
        }
    }
}
```

#### Error Handling:
- Network connection errors
- Purchase cancelled by user
- Product already purchased
- Receipt validation failed
- App Store unavailable

#### UI States to Handle:
- Loading products
- Purchase in progress
- Purchase successful
- Error messages
- Restore in progress

### 8. Testing Checklist

- [ ] RevenueCat API key configured
- [ ] Products created in App Store Connect
- [ ] Products load correctly from RevenueCat
- [ ] Monthly subscription purchase works
- [ ] Annual subscription purchase works
- [ ] Lifetime purchase works
- [ ] Premium status persists after app restart
- [ ] WindMapCard properly locks/unlocks
- [ ] Restore purchases functionality works
- [ ] Subscription renewal works (sandbox)
- [ ] Error handling for all edge cases
- [ ] Family sharing works correctly

### 9. Files to Create/Modify

1. **NEW** `Services/PremiumStore.swift` - Premium state management
2. **NEW** `Views/PremiumLockOverlay.swift` - Reusable lock UI
3. **NEW** `F1DashProducts.storekit` - Testing configuration
4. **UPDATE** `F1DashAppXCodeApp.swift` - Initialize RevenueCat
5. **UPDATE** `Views/PaywallMarqueeView.swift` - Wire up purchases
6. **UPDATE** `Features/Dashboard/WindMapCard.swift` - Add premium check
7. **UPDATE** `Services/SettingsStore.swift` - Add helper property for premium status

### 10. RevenueCat Dashboard Configuration

1. Create new project in RevenueCat
2. Add iOS app with bundle ID
3. Configure products:
   - Add subscription group "F1 Dash Premium"
   - Add monthly and annual auto-renewable subscriptions
   - Add lifetime non-consumable purchase
4. Create "premium" entitlement
5. Map all products to the entitlement
6. Configure sandbox testing environment
7. Get API keys for development and production

### 11. App Store Connect Setup

1. Create subscription group "F1 Dash Premium"
2. Add auto-renewable subscriptions:
   - Monthly: $0.99
   - Annual: $2.99 (25% discount)
3. Add non-consumable in-app purchase:
   - Lifetime: $4.99
4. Configure subscription benefits
5. Add localized descriptions
6. Submit for review with first app update

## Notes

- RevenueCat handles receipt validation automatically
- Premium status syncs across devices via iCloud (swift-sharing)
- No user authentication required - tied to Apple ID
- Family sharing supported automatically
- Subscription management handled by iOS Settings app