//
//  TrainHubView.swift
//  KyrieAI
//
//  Browse all training modes and the player's skill-plan focus.
//

import SwiftUI
import SwiftData

struct TrainHubView: View {
    @Bindable var profile: PlayerProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreViewModel.self) private var store
    @State private var sessionMode: TrainingMode? = nil
    @State private var showFullPlan: Bool = false
    @State private var showRetakeConfirm: Bool = false
    @State private var showPaywall: Bool = false

    /// Launch a training session, gating it behind a Pro subscription.
    private func launch(_ mode: TrainingMode) {
        if store.isPremium {
            sessionMode = mode
        } else {
            Haptics.warning()
            showPaywall = true
        }
    }

    var body: some View {
        ZStack {
            ArenaBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    todaysPlan
                    planFocus
                    SectionHeader(title: "All Modes")
                    VStack(spacing: 14) {
                        ForEach(TrainingModeCatalog.all) { mode in
                            Button {
                                Haptics.tap()
                                launch(mode)
                            } label: {
                                ModeRow(mode: mode, recommended: isRecommended(mode))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .fullScreenCover(item: $sessionMode) { mode in
            TrainingSessionView(profile: profile, mode: mode)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(store: store, context: "Unlock every training mode and your custom plan")
        }
        .sheet(isPresented: $showFullPlan) {
            FullPlanView(profile: profile)
        }
        .confirmationDialog(
            "Retake the welcome quiz?",
            isPresented: $showRetakeConfirm,
            titleVisibility: .visible
        ) {
            Button("Retake Quiz", role: .destructive) { retakeQuiz() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This restarts the welcome quiz and builds a fresh training plan. Your current profile will be cleared.")
        }
    }

    private func retakeQuiz() {
        Haptics.warning()
        modelContext.delete(profile)
        try? modelContext.save()
    }

    private func isRecommended(_ mode: TrainingMode) -> Bool {
        !Set(mode.focus).isDisjoint(with: Set(profile.weakestCategories))
    }

    /// The recommended plan for today: rotates daily through the modes that target
    /// the player's weakest skills, so each day surfaces a different custom workout.
    private var recommendedMode: TrainingMode {
        TrainingModeCatalog.mode(for: Date(), weakest: profile.weakestCategories)
    }

    private var todaysPlan: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Today's Plan")
            Button {
                Haptics.tap()
                launch(recommendedMode)
            } label: {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: recommendedMode.icon)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(recommendedMode.tint)
                            .frame(width: 52, height: 52)
                            .background(recommendedMode.tint.opacity(0.15), in: .rect(cornerRadius: 14))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recommendedMode.title)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Theme.textPrimary)
                            Text(recommendedMode.tagline)
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                    }
                    HStack {
                        Label("\(recommendedMode.defaultReps) moves", systemImage: "list.number")
                        Spacer()
                        Label("~8 min", systemImage: "clock")
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(recommendedMode.tint)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                }
                .padding(18)
                .background(
                    LinearGradient(colors: [recommendedMode.tint.opacity(0.18), Theme.surface], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .rect(cornerRadius: Theme.radiusL)
                )
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusL).strokeBorder(recommendedMode.tint.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TRAIN")
                    .font(Theme.body(14).weight(.heavy)).tracking(2)
                    .foregroundStyle(Theme.primary)
                Text("Choose your work")
                    .font(Theme.display(32))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            settingsButton
        }
    }

    private var settingsButton: some View {
        Menu {
            Button {
                Haptics.tap()
                showFullPlan = true
            } label: {
                Label("View Full Plan", systemImage: "list.bullet.rectangle.portrait")
            }
            Button {
                Haptics.tap()
                showRetakeConfirm = true
            } label: {
                Label("Retake Quiz", systemImage: "arrow.clockwise")
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 44, height: 44)
                .background(Theme.surfaceElevated, in: .circle)
                .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
        }
        .onTapGesture { Haptics.light() }
    }

    private var planFocus: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "target").foregroundStyle(Theme.energy)
                Text("Your Plan Focus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            Text("Based on your assessment, Coach is pushing these areas:")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            HStack(spacing: 10) {
                ForEach(profile.weakestCategories) { cat in
                    HStack(spacing: 6) {
                        Image(systemName: cat.icon).font(.caption.weight(.bold))
                        Text(cat.rawValue).font(.caption.weight(.bold))
                    }
                    .foregroundStyle(cat.color)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(cat.color.opacity(0.14), in: .capsule)
                }
            }
        }
        .glassCard()
    }
}

struct ModeRow: View {
    let mode: TrainingMode
    var recommended: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: mode.icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(mode.tint)
                .frame(width: 54, height: 54)
                .background(mode.tint.opacity(0.15), in: .rect(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(mode.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    if recommended {
                        TagPill(text: "FOR YOU", color: Theme.energy, filled: true)
                    }
                }
                Text(mode.tagline)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.textTertiary)
        }
        .glassCard(padding: 14)
    }
}
