//
//  KyrieAIApp.swift
//  KyrieAI
//
//  Created by Rork on June 6, 2026.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct KyrieAIApp: App {
    @State private var store = StoreViewModel()
    @State private var paywallRouter = PaywallRouter()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // RevenueCat key selection.
        //
        // The Test Store key (test_...) is ONLY valid in Debug builds — RevenueCat
        // intentionally crashes at launch if a Test Store key is used in a Release
        // build (which is what the Rork preview and App Store builds compile as).
        // So we must gate it behind #if DEBUG and use the production iOS key for
        // every Release build, falling back to the test key only if production is
        // somehow empty.
        Purchases.logLevel = .debug
        let apiKey: String
        #if DEBUG
        let testKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        apiKey = testKey.isEmpty ? Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY : testKey
        #else
        let prodKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        apiKey = prodKey.isEmpty ? Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY : prodKey
        #endif
        Purchases.configure(withAPIKey: apiKey)
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        // Meta App Events for ad conversion tracking / attribution.
        FacebookService.configure()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlayerProfile.self,
            SessionRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(store)
                .environment(paywallRouter)
                .onAppear {
                    Haptics.prepareAll()
                    SoundFX.prepareAll()
                    NotificationDelegate.shared.router = paywallRouter
                    FacebookService.requestTrackingAuthorization()
                }
                .onOpenURL { url in
                    paywallRouter.handle(url: url)
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                // User left without subscribing — tease the hidden half-off offer.
                if !store.isPremium { NotificationManager.scheduleDiscountOffer() }
            case .active:
                // Back in the app: cancel the pending tease.
                NotificationManager.cancelDiscountOffer()
                FacebookService.activate()
            default:
                break
            }
        }
    }
}
