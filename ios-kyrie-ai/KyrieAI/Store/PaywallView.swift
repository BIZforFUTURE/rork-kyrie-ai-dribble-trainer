//
//  PaywallView.swift
//  KyrieAI
//
//  Premium subscription paywall. Lists packages from the current
//  RevenueCat offering with a 3-day free trial highlight on the yearly plan.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    var store: StoreViewModel
    /// Short context line describing what the user was trying to unlock.
    var context: String = "Unlock your full training experience"
    /// When false, hides the close (X) button so the paywall acts as a hard gate.
    var allowClose: Bool = true

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: Package?
    @State private var appear = false
    // Hidden "Easter egg" basketball that drifts across the screen.
    @State private var showDiscountPaywall = false
    /// Reference time the ball started drifting; used to count off-screen passes.
    @State private var ballStart: Date?

    private let perks: [(String, String)] = [
        ("camera.metering.center.weighted", "AI skill assessment & Ball Handler Score"),
        ("figure.basketball", "Unlimited daily workouts & training modes"),
        ("waveform", "Real-time voice coaching during sessions"),
        ("chart.line.uptrend.xyaxis", "Progress tracking & personalized plans"),
    ]

    /// Formats the yearly plan's monthly-equivalent price (yearlyPrice / 12).
    private func monthlyEquivalent(for product: StoreProduct) -> String? {
        let yearlyPrice = product.price as Decimal
        var monthly = yearlyPrice / 12
        var rounded = Decimal()
        NSDecimalRound(&rounded, &monthly, 2, .plain)
        let currencySymbol = String(product.localizedPriceString.prefix { !$0.isNumber })
        return "\(currencySymbol)\(rounded)"
    }

    var body: some View {
        ZStack {
            ArenaBackground()
            Group {
                if store.isLoading && store.offerings == nil {
                    ProgressView().tint(Theme.primary)
                } else if let current = store.offerings?.current {
                    // The hidden half-off offer lives as a package inside this
                    // offering — exclude it so it only ever appears on the secret
                    // paywall, never alongside the normal plans.
                    content(current.availablePackages.filter {
                        $0.storeProduct.productIdentifier != StoreViewModel.discountProductID
                    })
                } else {
                    ContentUnavailableView {
                        Label("Plans Unavailable", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("We couldn't load subscription options. Check your connection and try again.")
                    } actions: {
                        Button("Retry") { Task { await store.fetchOfferings() } }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.primary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .overlay { secretBasketball }
        .onAppear { if ballStart == nil { ballStart = Date() } }
        .overlay(alignment: .topTrailing) { if allowClose { closeButton } }
        .fullScreenCover(isPresented: $showDiscountPaywall) {
            SecretDiscountPaywallView(store: store)
        }
        .alert("Something went wrong", isPresented: .init(
            get: { store.error != nil },
            set: { if !$0 { store.error = nil } }
        )) {
            Button("OK") { store.error = nil }
        } message: {
            Text(store.error ?? "")
        }
        .onChange(of: store.isPremium) { _, isPremium in
            guard isPremium else { return }
            // Close the secret discount cover first (if open), then dismiss the
            // paywall itself on the next runloop. Calling dismiss() while the
            // cover is still presented gets swallowed, leaving this paywall stuck.
            if showDiscountPaywall {
                showDiscountPaywall = false
                DispatchQueue.main.async { dismiss() }
            } else {
                dismiss()
            }
        }
        .task {
            if store.offerings == nil { await store.fetchOfferings() }
            // Default selection: prefer annual (best value).
            if selectedPackage == nil, let current = store.offerings?.current {
                selectedPackage = current.annual ?? current.availablePackages.first
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) { appear = true }
        }
    }

    /// A spinning basketball that slowly drifts diagonally across the paywall.
    /// Tapping it reveals the hidden half-off yearly offer.
    ///
    /// Motion is driven by `TimelineView` (not implicit animation) so the
    /// rendered position always matches the button's hit-testing frame —
    /// otherwise taps would miss the visibly-moving ball.
    private var secretBasketball: some View {
        GeometryReader { geo in
            let size: CGFloat = 188
            let driftDuration: Double = 9
            let spinDuration: Double = 1.1
            let maxPasses: Double = 2
            TimelineView(.animation) { timeline in
                let start = ballStart ?? timeline.date
                let elapsed = timeline.date.timeIntervalSince(start)
                // Hide the ball after it has drifted off-screen `maxPasses` times.
                if elapsed < driftDuration * maxPasses {
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let progress = CGFloat((elapsed.truncatingRemainder(dividingBy: driftDuration)) / driftDuration)
                    let spin = (t.truncatingRemainder(dividingBy: spinDuration)) / spinDuration * 360
                    let x = -size + progress * (geo.size.width + size * 2)
                    let y = geo.size.height * 0.18 + sin(progress * .pi * 2) * (geo.size.height * 0.28)
                    let bob = sin(t * 3) * 6
                    Button {
                        Haptics.tap()
                        showDiscountPaywall = true
                    } label: {
                        ZStack {
                            Image(systemName: "basketball.fill")
                                .font(.system(size: size))
                                .foregroundStyle(Theme.fireGradient)
                                .shadow(color: Theme.primary.opacity(0.7), radius: 16)
                                .rotationEffect(.degrees(spin))
                            Image(systemName: "hand.point.down.fill")
                                .font(.system(size: size * 0.4, weight: .bold))
                                .foregroundStyle(Theme.primary)
                                .shadow(color: .black.opacity(0.4), radius: 6)
                                .offset(y: -size * 0.72 + bob)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: size, height: size)
                    .contentShape(.circle)
                    .position(x: x, y: y)
                }
            }
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

    private func content(_ packages: [Package]) -> some View {
        ScrollView {
            VStack(spacing: 26) {
                hero
                perksCard
                VStack(spacing: 12) {
                    ForEach(packages, id: \.identifier) { package in
                        planRow(package)
                    }
                }
                purchaseButton
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
                Circle().fill(Theme.primary.opacity(0.18)).frame(width: 130).blur(radius: 26)
                Image(systemName: "basketball.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.fireGradient)
                    .shadow(color: Theme.primary.opacity(0.6), radius: 16)
            }
            .scaleEffect(appear ? 1 : 0.6)
            VStack(spacing: 8) {
                Text("KYRIE AI PRO")
                    .font(Theme.body(15).weight(.heavy)).tracking(3)
                    .foregroundStyle(Theme.primary)
                Text("Train Like a Pro")
                    .font(Theme.display(38)).tracking(1)
                    .foregroundStyle(Theme.textPrimary)
                Text(context)
                    .font(Theme.body(18)).tracking(0.3)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .opacity(appear ? 1 : 0)
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

    private func planRow(_ package: Package) -> some View {
        let isSelected = selectedPackage?.identifier == package.identifier
        let product = package.storeProduct
        let isAnnual = package.packageType == .annual

        return Button {
            Haptics.select()
            withAnimation(.snappy) { selectedPackage = package }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Theme.primary : Theme.stroke, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle().fill(Theme.primary).frame(width: 14, height: 14)
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(isAnnual ? "Yearly" : "Monthly")
                            .font(Theme.display(22))
                            .foregroundStyle(Theme.textPrimary)
                        if isAnnual {
                            TagPill(text: "BEST VALUE", color: Theme.energy, filled: true)
                        }
                    }
                    if isAnnual, let monthlyPrice = monthlyEquivalent(for: product) {
                        if let trial = store.freeTrialLabel(package) {
                            Text("\(trial) free trial, then \(monthlyPrice)/mo (\(product.localizedPriceString)/yr)")
                                .font(.caption)
                                .foregroundStyle(Theme.energy)
                        } else {
                            Text("\(monthlyPrice)/mo, billed annually (\(product.localizedPriceString)/yr)")
                                .font(.caption)
                                .foregroundStyle(Theme.energy)
                        }
                    } else if let trial = store.freeTrialLabel(package) {
                        Text("\(trial) free trial, then \(product.localizedPriceString)/mo")
                            .font(.caption)
                            .foregroundStyle(Theme.energy)
                    } else {
                        Text("Billed monthly, \(product.localizedPriceString)/mo")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer(minLength: 0)
                if isAnnual, let monthlyPrice = monthlyEquivalent(for: product) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(monthlyPrice)
                            .font(Theme.display(24))
                            .foregroundStyle(Theme.textPrimary)
                        Text("/mo")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.energy)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(product.localizedPriceString)
                            .font(Theme.display(24))
                            .foregroundStyle(Theme.textPrimary)
                        Text("/mo")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .padding(16)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(isSelected ? Theme.primary : Theme.stroke, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var purchaseButton: some View {
        let isAnnual = selectedPackage?.packageType == .annual
        let trialLabel = selectedPackage.flatMap { store.freeTrialLabel($0) }
        let buttonTitle: String = {
            if store.isPurchasing { return "Processing…" }
            if trialLabel != nil { return "Start Free Trial" }
            return "Subscribe"
        }()
        let caption: String = {
            if let trialLabel {
                return isAnnual
                    ? "\(trialLabel) free, then billed annually. Cancel anytime."
                    : "\(trialLabel) free, then billed monthly. Cancel anytime."
            }
            return isAnnual ? "Billed annually. Cancel anytime." : "Billed monthly. Cancel anytime."
        }()
        return VStack(spacing: 8) {
            PrimaryButton(
                title: buttonTitle,
                icon: store.isPurchasing ? nil : "bolt.fill",
                enabled: selectedPackage != nil && !store.isPurchasing
            ) {
                guard let package = selectedPackage else { return }
                Task { await store.purchase(package: package) }
            }
            Text(caption)
                .font(.caption2)
                .foregroundStyle(Theme.textTertiary)
        }
    }

    private var promoCodeButton: some View {
        Button {
            Haptics.light()
            store.presentCodeRedemptionSheet()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "ticket.fill")
                    .font(.caption.weight(.bold))
                Text("Redeem Offer Code")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Theme.textSecondary)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Theme.surface, in: .capsule)
            .overlay(
                Capsule()
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 14) {
            promoCodeButton

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

private extension SubscriptionPeriod {
    /// A short human label like "3-day" / "1-week" for intro periods.
    var periodTitle: String {
        let unitName: String
        switch unit {
        case .day: unitName = "day"
        case .week: unitName = "week"
        case .month: unitName = "month"
        case .year: unitName = "year"
        @unknown default: unitName = "period"
        }
        return "\(value)-\(unitName)"
    }
}
