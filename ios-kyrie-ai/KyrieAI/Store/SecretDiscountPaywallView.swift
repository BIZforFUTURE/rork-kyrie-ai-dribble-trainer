//
//  SecretDiscountPaywallView.swift
//  KyrieAI
//
//  Hidden "Kyrie Pro Discounted" paywall, revealed by tapping the spinning
//  basketball on the main paywall. Offers the half-off yearly plan
//  (product ID: "discountyearly") at $29.99/year.
//

import SwiftUI
import RevenueCat

struct SecretDiscountPaywallView: View {
    var store: StoreViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var appear = false

    private let perks: [(String, String)] = [
        ("camera.metering.center.weighted", "AI skill assessment & Ball Handler Score"),
        ("figure.basketball", "Unlimited daily workouts & training modes"),
        ("waveform", "Real-time voice coaching during sessions"),
        ("chart.line.uptrend.xyaxis", "Progress tracking & personalized plans"),
    ]

    var body: some View {
        ZStack {
            ArenaBackground()
            Group {
                if store.isLoadingDiscount && store.discountProduct == nil {
                    ProgressView().tint(Theme.primary)
                } else if let product = store.discountProduct {
                    content(product)
                } else {
                    ContentUnavailableView {
                        Label("Offer Unavailable", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("We couldn't load this offer. Check your connection and try again.")
                    } actions: {
                        Button("Retry") { Task { await store.fetchDiscountProduct() } }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.primary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .topTrailing) { closeButton }
        .alert("Something went wrong", isPresented: .init(
            get: { store.error != nil },
            set: { if !$0 { store.error = nil } }
        )) {
            Button("OK") { store.error = nil }
        } message: {
            Text(store.error ?? "")
        }
        .onChange(of: store.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
        .task {
            await store.fetchDiscountProduct()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { appear = true }
        }
    }

    private var closeButton: some View {
        Button {
            Haptics.light()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 34, height: 34)
                .background(.ultraThinMaterial, in: .circle)
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
        .padding(.trailing, 18)
    }

    private func monthlyEquivalent(for product: StoreProduct) -> String {
        let yearlyPrice = product.price as Decimal
        var monthly = yearlyPrice / 12
        var rounded = Decimal()
        NSDecimalRound(&rounded, &monthly, 2, .plain)
        let currencySymbol = String(product.localizedPriceString.prefix { !$0.isNumber })
        return "\(currencySymbol)\(rounded)"
    }

    private func content(_ product: StoreProduct) -> some View {
        ScrollView {
            VStack(spacing: 26) {
                hero
                offerCard(product)
                perksCard
                purchaseButton(product)
                footer
            }
            .padding(.horizontal, 22)
            .padding(.top, 40)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
    }

    private var hero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Theme.energy.opacity(0.18)).frame(width: 130).blur(radius: 26)
                Image(systemName: "gift.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(Theme.energyGradient)
                    .shadow(color: Theme.energy.opacity(0.6), radius: 16)
            }
            .scaleEffect(appear ? 1 : 0.6)
            VStack(spacing: 8) {
                Text("OFFER UNLOCKED")
                    .font(Theme.body(15).weight(.heavy)).tracking(3)
                    .foregroundStyle(Theme.energy)
                Text("SECRET")
                    .font(Theme.display(82))
                    .tracking(3)
                    .foregroundStyle(Theme.energyGradient)
                    .shadow(color: Theme.energy.opacity(0.5), radius: 18, y: 6)
                    .scaleEffect(appear ? 1 : 0.7)
            }
        }
        .opacity(appear ? 1 : 0)
    }

    private func offerCard(_ product: StoreProduct) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                TagPill(text: "50% OFF", color: Theme.energy, filled: true)
                Text("Limited time")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(product.localizedPriceString)
                    .font(Theme.display(50))
                    .foregroundStyle(Theme.textPrimary)
                Text("/yr")
                    .font(Theme.display(24))
                    .foregroundStyle(Theme.energy)
            }
            Text("Just \(monthlyEquivalent(for: product))/mo, billed annually")
                .font(Theme.body(17))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusL))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusL)
                .strokeBorder(Theme.energy.opacity(0.5), lineWidth: 1.5)
        )
        .shadow(color: Theme.energy.opacity(0.18), radius: 18, y: 8)
    }

    private var perksCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(perks.enumerated()), id: \.offset) { _, perk in
                HStack(spacing: 14) {
                    Image(systemName: perk.0)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.primary)
                        .frame(width: 34, height: 34)
                        .background(Theme.primary.opacity(0.14), in: .circle)
                    Text(perk.1)
                        .font(Theme.body(17))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer(minLength: 0)
                }
            }
        }
        .glassCard()
    }

    private func purchaseButton(_ product: StoreProduct) -> some View {
        VStack(spacing: 8) {
            PrimaryButton(
                title: store.isPurchasing ? "Processing…" : "Claim 50% Off",
                icon: store.isPurchasing ? nil : "bolt.fill",
                gradient: Theme.energyGradient,
                enabled: !store.isPurchasing
            ) {
                Task { await store.purchaseDiscount() }
            }
            Text("Billed annually at \(product.localizedPriceString)/yr. Cancel anytime.")
                .font(.caption2)
                .foregroundStyle(Theme.textTertiary)
        }
    }

    private var footer: some View {
        VStack(spacing: 14) {
            Button {
                Haptics.light()
                Task { await store.restore() }
            } label: {
                HStack(spacing: 6) {
                    if store.isRestoring { ProgressView().tint(Theme.textSecondary) }
                    Text("Restore Purchases")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .disabled(store.isRestoring)

            Text("Payment is charged to your Apple ID. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the period.")
                .font(.caption2)
                .foregroundStyle(Theme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            HStack(spacing: 6) {
                Link("Terms of Use", destination: URL(string: "https://p-isjxf9gj1lwsmsjtmbjze.rork.live/terms")!)
                Text("·").foregroundStyle(Theme.textTertiary)
                Link("Privacy Policy", destination: URL(string: "https://p-isjxf9gj1lwsmsjtmbjze.rork.live/privacy")!)
            }
            .font(.caption2.weight(.semibold))
            .tint(Theme.textSecondary)
        }
    }
}
