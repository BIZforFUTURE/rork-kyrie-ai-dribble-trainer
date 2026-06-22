//
//  PaywallGateView.swift
//  KyrieAI
//
//  Onboarding paywall step. Presented right after onboarding and before the
//  skill assessment. The player can close (X) this paywall and proceed to the
//  assessment screen, but starting the assessment itself still requires an
//  active subscription (enforced in AssessmentView).
//

import SwiftUI
import SwiftData

struct PaywallGateView: View {
    let profile: PlayerProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreViewModel.self) private var store
    @State private var showPaywall = true

    var body: some View {
        ZStack { ArenaBackground() }
            .preferredColorScheme(.dark)
            .fullScreenCover(isPresented: $showPaywall, onDismiss: advance) {
                PaywallView(store: store, context: "Unlock your full plan, profile & training", allowClose: true)
            }
            .onChange(of: store.isPremium) { _, isPremium in
                if isPremium { advance() }
            }
    }

    /// Mark the paywall as seen so the router moves on to the assessment.
    private func advance() {
        guard !profile.hasSeenPaywall else { return }
        profile.hasSeenPaywall = true
        try? modelContext.save()
    }
}
