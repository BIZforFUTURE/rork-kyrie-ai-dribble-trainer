//
//  ProfileView.swift
//  KyrieAI
//
//  Player profile: stats, goals, achievements, and settings.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Bindable var profile: PlayerProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreViewModel.self) private var store
    @State private var showResetConfirm = false
    @State private var showEditStats = false
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            ArenaBackground()
            ScrollView {
                VStack(spacing: 22) {
                    headerCard
                    subscriptionCard
                    statsSection
                    goalsCard
                    achievementsCard
                    resetButton
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .confirmationDialog("Reset all progress?", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset everything", role: .destructive) { resetProfile() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes your profile, score, and session history.")
        }
        .sheet(isPresented: $showEditStats) {
            EditStatsSheet(profile: profile)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(store: store)
        }
    }

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: store.isPremium ? "crown.fill" : "bolt.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex: 0x140A04))
                    .frame(width: 44, height: 44)
                    .background(Theme.fireGradient, in: .circle)
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.isPremium ? "Kyrie AI Pro" : "Go Pro")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(store.isPremium
                         ? "You're a Pro member — train without limits."
                         : "Unlock assessments, workouts & coaching.")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: 0)
                if store.isPremium {
                    TagPill(text: "ACTIVE", color: Theme.energy, filled: true)
                }
            }
            if !store.isPremium {
                PrimaryButton(title: "Upgrade to Pro", icon: "sparkles") {
                    showPaywall = true
                }
            }
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .disabled(store.isRestoring)

            HStack(spacing: 6) {
                Link("Terms of Use", destination: URL(string: "https://p-isjxf9gj1lwsmsjtmbjze.rork.live/terms")!)
                Text("·").foregroundStyle(Theme.textTertiary)
                Link("Privacy Policy", destination: URL(string: "https://p-isjxf9gj1lwsmsjtmbjze.rork.live/privacy")!)
            }
            .font(.caption2.weight(.semibold))
            .tint(Theme.textSecondary)
            .frame(maxWidth: .infinity)
        }
        .glassCard()
        .alert("Restore", isPresented: .init(
            get: { store.error != nil },
            set: { if !$0 { store.error = nil } }
        )) {
            Button("OK") { store.error = nil }
        } message: {
            Text(store.error ?? "")
        }
    }

    private var headerCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(Theme.fireGradient).frame(width: 96, height: 96)
                Text(initials).font(.system(size: 36, weight: .black, design: .rounded)).foregroundStyle(Color(hex: 0x140A04))
            }
            .shadow(color: Theme.primary.opacity(0.5), radius: 18)
            VStack(spacing: 4) {
                Text(profile.name.isEmpty ? "Hooper" : profile.name)
                    .font(Theme.display(30))
                    .foregroundStyle(Theme.textPrimary)
                Text("\(profile.position.rawValue) · \(profile.skillLevel.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            HStack(spacing: 10) {
                TagPill(text: profile.tier.uppercased(), color: Theme.primary, filled: true)
                TagPill(text: "\(profile.dominantHand.rawValue) handed".uppercased(), color: Theme.info)
            }
        }
        .frame(maxWidth: .infinity)
        .glassCard(padding: 22)
    }

    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Stats").font(.headline.weight(.bold)).foregroundStyle(Theme.textPrimary)
                Spacer()
                Button {
                    Haptics.light()
                    showEditStats = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil").font(.caption.weight(.bold))
                        Text("Edit").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Theme.primary.opacity(0.12), in: .capsule)
                }
                .buttonStyle(.plain)
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                StatChip(value: "\(profile.ballHandlerScore)", label: "Ball Handler Score", tint: Theme.primary, icon: "star.fill")
                StatChip(value: profile.heightFormatted, label: "Height", tint: Theme.info, icon: "ruler.fill")
                StatChip(value: "\(profile.age)", label: "Age", tint: Theme.energy, icon: "person.fill")
                StatChip(value: "\(profile.longestStreak)d", label: "Best streak", tint: Color(hex: 0xFFC53D), icon: "flame.fill")
            }
        }
    }

    private var goalsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Training Goals").font(.headline.weight(.bold)).foregroundStyle(Theme.textPrimary)
            if profile.goals.isEmpty {
                Text("No goals set.").font(.subheadline).foregroundStyle(Theme.textSecondary)
            } else {
                FlowChips(goals: profile.goals)
            }
            Divider().overlay(Theme.stroke)
            HStack {
                Text("Schedule").font(.subheadline).foregroundStyle(Theme.textSecondary)
                Spacer()
                Text(profile.availability.rawValue).font(.subheadline.weight(.bold)).foregroundStyle(Theme.textPrimary)
            }
            if !profile.trainingDays.isEmpty {
                HStack(spacing: 6) {
                    ForEach(profile.trainingDays) { day in
                        Text(day.short)
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(Theme.energy)
                            .frame(width: 32, height: 32)
                            .background(Theme.energy.opacity(0.12), in: .circle)
                    }
                }
            }
        }
        .glassCard()
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Achievements").font(.headline.weight(.bold)).foregroundStyle(Theme.textPrimary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                badge("flame.fill", "First Streak", profile.currentStreak >= 1, Theme.primary)
                badge("bolt.fill", "1K XP", profile.totalXP >= 1000, Theme.energy)
                badge("scope", "Sharp", profile.controlScore >= 70, Theme.info)
                badge("hand.point.left.fill", "Ambidextrous", profile.weakHandScore >= 70, Theme.energy)
                badge("trophy.fill", "10 Sessions", profile.sessions.count >= 10, Color(hex: 0xFFC53D))
                badge("crown.fill", "Elite", profile.ballHandlerScore >= 85, Color(hex: 0xB06BFF))
            }
        }
        .glassCard()
    }

    private func badge(_ icon: String, _ title: String, _ unlocked: Bool, _ tint: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(unlocked ? tint : Theme.textTertiary)
                .frame(width: 56, height: 56)
                .background((unlocked ? tint : Theme.textTertiary).opacity(0.14), in: .circle)
                .overlay(Circle().strokeBorder(unlocked ? tint.opacity(0.5) : .clear, lineWidth: 1))
            Text(title).font(.caption2.weight(.semibold)).foregroundStyle(unlocked ? Theme.textPrimary : Theme.textTertiary).multilineTextAlignment(.center)
        }
    }

    private var resetButton: some View {
        Button(role: .destructive) {
            showResetConfirm = true
        } label: {
            Text("Reset Progress")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(hex: 0xFF5C5C))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: 0xFF5C5C).opacity(0.1), in: .rect(cornerRadius: Theme.radiusM))
        }
        .buttonStyle(.plain)
    }

    private var initials: String {
        let parts = profile.name.split(separator: " ")
        if let f = parts.first?.first {
            if parts.count > 1, let s = parts[1].first { return "\(f)\(s)" }
            return String(f)
        }
        return "K"
    }

    private func resetProfile() {
        modelContext.delete(profile)
        try? modelContext.save()
    }
}

/// Sheet for editing the player's physical stats (age + height).
struct EditStatsSheet: View {
    @Bindable var profile: PlayerProfile
    @Environment(\.dismiss) private var dismiss

    @State private var age: Int = 16
    @State private var heightInches: Int = 70

    var body: some View {
        NavigationStack {
            ZStack {
                ArenaBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        stepperCard(title: "Age", value: "\(age)",
                                    onMinus: { age = max(8, age - 1) },
                                    onPlus: { age = min(60, age + 1) })

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Height").font(.headline).foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text(heightString).font(.headline.weight(.bold)).foregroundStyle(Theme.primary)
                            }
                            Slider(value: Binding(
                                get: { Double(heightInches) },
                                set: { heightInches = Int($0) }
                            ), in: 48...84, step: 1)
                            .tint(Theme.primary)
                        }
                        .padding(16)
                        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
                        .overlay(RoundedRectangle(cornerRadius: Theme.radiusM).strokeBorder(Theme.stroke, lineWidth: 1))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Edit Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.bold)
                }
            }
            .onAppear {
                age = profile.age
                heightInches = profile.heightInches
            }
        }
        .preferredColorScheme(.dark)
    }

    private var heightString: String {
        "\(heightInches / 12)'\(heightInches % 12)\""
    }

    private func save() {
        Haptics.success()
        profile.age = age
        profile.heightInches = heightInches
        dismiss()
    }

    private func stepperCard(title: String, value: String, onMinus: @escaping () -> Void, onPlus: @escaping () -> Void) -> some View {
        HStack {
            Text(title).font(.headline).foregroundStyle(Theme.textPrimary)
            Spacer()
            HStack(spacing: 18) {
                circleButton("minus", action: onMinus)
                Text(value)
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(Theme.primary)
                    .frame(minWidth: 50)
                    .contentTransition(.numericText())
                circleButton("plus", action: onPlus)
            }
        }
        .padding(16)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusM).strokeBorder(Theme.stroke, lineWidth: 1))
    }

    private func circleButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(.snappy) { action() }
        } label: {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 40, height: 40)
                .background(Theme.surfaceElevated, in: .circle)
                .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

/// Wrapping chips for goals.
struct FlowChips: View {
    let goals: [TrainingGoal]
    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(goals) { goal in
                HStack(spacing: 6) {
                    Image(systemName: goal.icon).font(.caption2.weight(.bold))
                    Text(goal.rawValue).font(.caption.weight(.semibold))
                }
                .foregroundStyle(Theme.energy)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Theme.energy.opacity(0.12), in: .capsule)
            }
        }
    }
}
