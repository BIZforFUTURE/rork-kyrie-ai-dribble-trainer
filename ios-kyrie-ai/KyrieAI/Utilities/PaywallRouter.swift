//
//  PaywallRouter.swift
//  KyrieAI
//
//  Routes notification taps (e.g. the win-back discount offer) into the
//  appropriate in-app paywall, and presents banners while the app is open.
//

import SwiftUI
import UserNotifications

/// Shared, observable routing state for paywall deep-links triggered outside
/// the normal UI flow (currently the win-back discount notification).
@Observable
@MainActor
final class PaywallRouter {
    /// When true, the root view presents the secret half-off discount paywall.
    var showSecretDiscount = false
    /// When true, the root view presents the standard subscription paywall.
    /// Driven by the `kyrieai://paywall` deep link.
    var showPaywall = false
    /// When true, the root view restarts onboarding from the welcome step.
    /// Driven by the `kyrieai://start` deep link (cold ad traffic).
    var showOnboarding = false

    /// Routes an incoming deep-link URL (e.g. `kyrieai://paywall`) to the
    /// matching paywall. Returns true when the URL was handled.
    @discardableResult
    func handle(url: URL) -> Bool {
        guard url.scheme?.lowercased() == "kyrieai" else { return false }
        // Accept both kyrieai://paywall and kyrieai:///paywall style links.
        let target = (url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))).lowercased()
        switch target {
        case "paywall", "pro", "subscribe", "upgrade":
            showPaywall = true
            return true
        case "discount", "offer", "secret":
            showSecretDiscount = true
            return true
        case "start", "onboarding", "begin", "welcome":
            showOnboarding = true
            return true
        default:
            return false
        }
    }
}

/// Handles notification delivery while the app is foregrounded and routes taps
/// to the correct destination via the shared `PaywallRouter`.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    /// Set on launch so taps can update navigation state.
    @MainActor var router: PaywallRouter?

    /// Show win-back banners even when the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// Route a tapped notification to its destination.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let destination = response.notification.request.content
            .userInfo[NotificationManager.destinationKey] as? String
        Task { @MainActor in
            if destination == NotificationManager.secretDiscountDestination {
                self.router?.showSecretDiscount = true
            }
        }
        completionHandler()
    }
}
