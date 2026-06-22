//
//  ContentView.swift
//  KyrieAI
//
//  Root router: onboarding → assessment → main app, driven by the
//  persisted PlayerProfile.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [PlayerProfile]
    @Environment(StoreViewModel.self) private var store
    @Environment(PaywallRouter.self) private var router

    private var profile: PlayerProfile? { profiles.first }

    var body: some View {
        Group {
            if let profile {
                if !profile.hasOnboarded {
                    OnboardingView()
                } else if !profile.hasSeenPaywall {
                    PaywallGateView(profile: profile)
                        .transition(.opacity)
                } else if !profile.hasAssessment {
                    AssessmentView(profile: profile)
                        .transition(.opacity)
                } else {
                    MainTabView(profile: profile)
                        .transition(.opacity)
                }
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: profile?.hasOnboarded)
        .animation(.easeInOut(duration: 0.4), value: profile?.hasSeenPaywall)
        .animation(.easeInOut(duration: 0.4), value: profile?.hasAssessment)
        .fullScreenCover(isPresented: Binding(
            get: { router.showSecretDiscount && !store.isPremium },
            set: { if !$0 { router.showSecretDiscount = false } }
        )) {
            SecretDiscountPaywallView(store: store)
        }
        .fullScreenCover(isPresented: Binding(
            get: { router.showPaywall && !store.isPremium },
            set: { if !$0 { router.showPaywall = false } }
        )) {
            PaywallView(store: store)
        }
        .fullScreenCover(isPresented: Binding(
            get: { router.showOnboarding },
            set: { if !$0 { router.showOnboarding = false } }
        )) {
            OnboardingView(existingProfile: profile) {
                router.showOnboarding = false
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PlayerProfile.self, inMemory: true)
}

