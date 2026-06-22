//
//  FacebookService.swift
//  KyrieAI
//
//  Wraps Meta's Facebook SDK (App Events) for ad conversion tracking and
//  attribution. We only use App Events — no Login or Sharing — so the goal
//  is to report installs, app activations, and subscription purchases back
//  to Meta for ad measurement on iOS 14.5+.
//
//  NOTE: Meta ships the Facebook SDK as a *binary* XCFramework over Swift
//  Package Manager, which Rork's cloud builder cannot resolve. The whole
//  integration is therefore guarded behind `#if canImport(FBSDKCoreKit)`:
//  it compiles as a no-op in the Rork preview, and lights up automatically
//  once the package is added in Xcode on a Mac (File > Add Package
//  Dependencies > https://github.com/facebook/facebook-ios-sdk, product
//  `FBSDKCoreKit`).
//

import Foundation
import UIKit
import AppTrackingTransparency
#if canImport(FBSDKCoreKit)
import FBSDKCoreKit
#endif

enum FacebookService {
    /// Configures the SDK with credentials and enables automatic event logging.
    /// Safe to call once at launch; no-ops if credentials are missing.
    static func configure() {
        #if canImport(FBSDKCoreKit)
        let appID = Config.EXPO_PUBLIC_FACEBOOK_APP_ID
        let clientToken = Config.EXPO_PUBLIC_FACEBOOK_CLIENT_TOKEN
        guard !appID.isEmpty, !clientToken.isEmpty else { return }

        Settings.shared.appID = appID
        Settings.shared.clientToken = clientToken
        Settings.shared.displayName = "Kyrie AI"
        Settings.shared.isAutoLogAppEventsEnabled = true

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
        #endif
    }

    /// Logs an app activation. Call when the app becomes active.
    static func activate() {
        #if canImport(FBSDKCoreKit)
        guard !Config.EXPO_PUBLIC_FACEBOOK_APP_ID.isEmpty else { return }
        AppEvents.shared.activateApp()
        #endif
    }

    /// Asks for App Tracking Transparency permission and reflects the result in
    /// the SDK so Meta only uses the advertising identifier when allowed.
    static func requestTrackingAuthorization() {
        #if canImport(FBSDKCoreKit)
        guard !Config.EXPO_PUBLIC_FACEBOOK_APP_ID.isEmpty else { return }
        ATTrackingManager.requestTrackingAuthorization { status in
            Task { @MainActor in
                Settings.shared.isAdvertiserTrackingEnabled = (status == .authorized)
            }
        }
        #endif
    }

    /// Logs a subscription purchase — the key conversion signal for Meta ads.
    static func logSubscription(amount: Double, currency: String) {
        #if canImport(FBSDKCoreKit)
        guard !Config.EXPO_PUBLIC_FACEBOOK_APP_ID.isEmpty else { return }
        AppEvents.shared.logPurchase(amount: amount, currency: currency)
        #endif
    }
}
