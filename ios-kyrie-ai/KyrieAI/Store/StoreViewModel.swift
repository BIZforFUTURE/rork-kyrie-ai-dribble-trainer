//
//  StoreViewModel.swift
//  KyrieAI
//
//  Central RevenueCat subscription state. Drives the paywall and gates
//  premium features (assessment, daily workout, training).
//

import Foundation
import Observation
import OSLog
import RevenueCat

private let storeLog = Logger(subsystem: "com.kyrieai.app", category: "Store")

@Observable
@MainActor
final class StoreViewModel {
    /// RevenueCat entitlement identifier configured in the dashboard.
    static let entitlementID = "Kyrie AI Pro"
    /// Product identifier for the hidden, half-off yearly offer ("Kyrie Pro Discounted").
    static let discountProductID = "discountyearly"

    var offerings: Offerings?
    var isPremium = false
    var isLoading = false
    var isPurchasing = false
    var isRestoring = false
    var error: String?
    /// The secret half-off yearly product, fetched lazily from RevenueCat.
    var discountProduct: StoreProduct?
    var isLoadingDiscount = false
    /// Per-product free-trial / intro-offer eligibility, keyed by product identifier.
    var introEligibility: [String: IntroEligibilityStatus] = [:]

    init() {
        Task { await listenForUpdates() }
        Task { await fetchOfferings() }
        Task { await checkStatus() }
    }

    /// True only when a package actually has an introductory free trial AND this
    /// user is eligible for it. Drives all trial messaging on the paywall so we
    /// never promise a trial Apple won't honor (which results in an instant charge).
    func hasEligibleFreeTrial(_ package: Package) -> Bool {
        guard let intro = package.storeProduct.introductoryDiscount,
              intro.paymentMode == .freeTrial else { return false }
        switch introEligibility[package.storeProduct.productIdentifier] {
        case .ineligible, .noIntroOfferExists:
            return false
        case .eligible, .unknown, .none:
            // No eligibility data yet (e.g. StoreKit testing) — trust the product's offer.
            return true
        @unknown default:
            return true
        }
    }

    /// A short label for a package's free-trial duration, e.g. "3-day".
    func freeTrialLabel(_ package: Package) -> String? {
        guard hasEligibleFreeTrial(package),
              let period = package.storeProduct.introductoryDiscount?.subscriptionPeriod else { return nil }
        let unitName: String
        switch period.unit {
        case .day: unitName = "day"
        case .week: unitName = "week"
        case .month: unitName = "month"
        case .year: unitName = "year"
        @unknown default: unitName = "day"
        }
        return "\(period.value)-\(unitName)"
    }

    /// Resolves Pro status from customer info. Prefers the configured entitlement,
    /// but falls back to ANY active entitlement so a slightly mismatched identifier
    /// in the dashboard never traps a paying user behind the paywall.
    private func resolvePremium(_ info: CustomerInfo) -> Bool {
        if info.entitlements[Self.entitlementID]?.isActive == true { return true }
        return !info.entitlements.active.isEmpty
    }

    /// Called after a purchase completes without cancellation or error. The
    /// transaction itself succeeded, so we grant Pro right away — this prevents
    /// the paywall from getting stuck when the returned `customerInfo` hasn't
    /// yet reflected the new entitlement (which routinely happens with the
    /// RevenueCat Test Store and with slow entitlement propagation in sandbox).
    /// We still re-sync from the server in the background to reconcile state.
    private func grantPremiumAfterPurchase(_ info: CustomerInfo, product: StoreProduct? = nil) {
        isPremium = true
        // Report the conversion to Meta for ad attribution.
        if let product {
            FacebookService.logSubscription(
                amount: NSDecimalNumber(decimal: product.price).doubleValue,
                currency: product.currencyCode ?? "USD"
            )
        }
        Task { await checkStatusKeepingPremium() }
    }

    /// Refreshes customer info but never downgrades a just-purchased user. If the
    /// server confirms an active entitlement we keep Pro; if it hasn't propagated
    /// yet we leave the optimistic unlock in place rather than bouncing the user
    /// back to the paywall.
    private func checkStatusKeepingPremium() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            if resolvePremium(info) { isPremium = true }
        } catch {
            storeLog.error("post-purchase customerInfo refresh failed: \(error.localizedDescription)")
        }
    }

    private func listenForUpdates() async {
        for await info in Purchases.shared.customerInfoStream {
            let premium = resolvePremium(info)
            storeLog.log("customerInfo stream update — active entitlements: \(Array(info.entitlements.active.keys)), premium: \(premium)")
            isPremium = premium
        }
    }

    func fetchOfferings() async {
        isLoading = true
        do {
            offerings = try await Purchases.shared.offerings()
            await refreshEligibility()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    /// Asks StoreKit which intro offers / free trials the user is still eligible for.
    private func refreshEligibility() async {
        guard let packages = offerings?.current?.availablePackages, !packages.isEmpty else { return }
        let identifiers = packages.map { $0.storeProduct.productIdentifier }
        let result = await Purchases.shared.checkTrialOrIntroDiscountEligibility(productIdentifiers: identifiers)
        introEligibility = result.mapValues { $0.status }
    }

    /// Loads the hidden half-off yearly product ("discountyearly") on demand.
    func fetchDiscountProduct() async {
        guard discountProduct == nil else { return }
        isLoadingDiscount = true
        let products = await Purchases.shared.products([Self.discountProductID])
        discountProduct = products.first
        isLoadingDiscount = false
    }

    /// Finds the secret discount as a package inside the current offering, if present.
    /// Used so the hidden offer is purchased with full offering/entitlement context.
    private var discountPackage: Package? {
        offerings?.current?.availablePackages.first {
            $0.storeProduct.productIdentifier == Self.discountProductID
        }
    }

    /// Purchases the hidden half-off yearly offer. Prefers the configured package
    /// (so the offering/entitlement context is attached); falls back to the raw product.
    func purchaseDiscount() async {
        isPurchasing = true
        defer { isPurchasing = false }
        var purchasedProduct: StoreProduct?
        do {
            // Make sure offerings are loaded so we can buy through the package
            // (which carries the offering/entitlement context). Fall back to the
            // raw product only if the package genuinely isn't available.
            if offerings == nil {
                offerings = try? await Purchases.shared.offerings()
            }
            if discountProduct == nil {
                await fetchDiscountProduct()
            }
            let result: PurchaseResultData
            if let package = discountPackage {
                storeLog.log("purchaseDiscount — buying package \(package.identifier)")
                result = try await Purchases.shared.purchase(package: package)
                purchasedProduct = package.storeProduct
            } else if let product = discountProduct {
                storeLog.log("purchaseDiscount — buying raw product \(product.productIdentifier)")
                result = try await Purchases.shared.purchase(product: product)
                purchasedProduct = product
            } else {
                storeLog.error("purchaseDiscount — no package or product available")
                error = "This offer is unavailable right now. Please try again."
                return
            }
            storeLog.log("purchaseDiscount completed — cancelled: \(result.userCancelled), active: \(Array(result.customerInfo.entitlements.active.keys))")
            if !result.userCancelled {
                // A non-cancelled purchase that threw no error means the
                // transaction succeeded, so unlock Pro immediately. We still
                // re-pull customer info to reconcile, but we never leave a
                // paying user stuck on the paywall when the returned
                // entitlements lag (common with the RevenueCat Test Store).
                grantPremiumAfterPurchase(result.customerInfo, product: purchasedProduct)
            }
        } catch ErrorCode.purchaseCancelledError {
            // StoreKit cancellation — not an error
        } catch ErrorCode.paymentPendingError {
            // Awaiting parental approval or extra auth — not a failure
        } catch {
            self.error = error.localizedDescription
        }
    }

    func purchase(package: Package) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            storeLog.log("purchase — buying package \(package.identifier) (\(package.storeProduct.productIdentifier))")
            let result = try await Purchases.shared.purchase(package: package)
            storeLog.log("purchase completed — cancelled: \(result.userCancelled), active: \(Array(result.customerInfo.entitlements.active.keys))")
            if !result.userCancelled {
                grantPremiumAfterPurchase(result.customerInfo, product: package.storeProduct)
            }
        } catch ErrorCode.purchaseCancelledError {
            // StoreKit cancellation — not an error
        } catch ErrorCode.paymentPendingError {
            // Awaiting parental approval or extra auth — not a failure
        } catch {
            self.error = error.localizedDescription
        }
        isPurchasing = false
    }

    func restore() async {
        isRestoring = true
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = resolvePremium(info)
            if !isPremium {
                error = "No active subscription found to restore."
            }
        } catch {
            self.error = error.localizedDescription
        }
        isRestoring = false
    }

    func checkStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isPremium = resolvePremium(info)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func presentCodeRedemptionSheet() {
        Purchases.shared.presentCodeRedemptionSheet()
    }
}
