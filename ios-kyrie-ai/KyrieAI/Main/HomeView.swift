//
//  HomeView.swift
//  KyrieAI
//
//  The daily training hub: greeting, score, streak, today's plan,
//  daily challenge, and quick access to modes.
//

import SwiftUI

struct HomeView: View {
    @Bindable var profile: PlayerProfile
    @Environment(StoreViewModel.self) private var store
    @State private var sessionMode: TrainingMode? = nil
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

    private var challenge: DailyChallenge { ChallengeFactory.today() }

    /// The recommended plan for today, derived from weakest skills + goals.
    private var recommendedMode: TrainingMode {
        let weak = profile.weakestCategories
        return TrainingModeCatalog.all.first { mode in
            !Set(mode.focus).isDisjoint(with: Set(weak))
        } ?? TrainingModeCatalog.all[0]
    }

    var body: some View {
        ZStack {
            ArenaBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    greeting
                    heroScoreCard
                    streakRow
                    todaysPlan
                    dailyChallengeCard
                    quickModes
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
            PaywallView(store: store, context: "Unlock unlimited daily workouts and training")
        }
        .onAppear { StreakWidgetSync.sync(from: profile) }
    }

    private var greeting: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText.uppercased())
                    .font(Theme.body(14).weight(.heavy)).tracking(2)
                    .foregroundStyle(Theme.primary)
                Text(profile.firstName)
                    .font(Theme.display(34))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            ZStack {
                Circle().fill(Theme.surface).frame(width: 52, height: 52)
                    .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
                Text(profile.position.short)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Theme.primary)
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var heroScoreCard: some View {
        VStack(spacing: 16) {
            Text("BALL HANDLER SCORE")
                .font(Theme.body(14).weight(.heavy)).tracking(2)
                .foregroundStyle(Theme.textSecondary)
            ScoreRing(progress: Double(profile.ballHandlerScore) / 100, size: 200, lineWidth: 16, gradient: AngularGradient(colors: [.white], center: .center), label: AnyView(
                VStack(spacing: 2) {
                    Text("\(profile.ballHandlerScore)")
                        .font(Theme.display(74))
                        .foregroundStyle(Theme.textPrimary)
                        .contentTransition(.numericText())
                    Text(profile.tier)
                        .font(Theme.body(17).weight(.bold))
                        .foregroundStyle(Theme.primary)
                }
            ))
            Text("Train today to push your rating higher.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .glassCard()
    }

    private var streakRow: some View {
        HStack(spacing: 12) {
            StatChip(value: "\(profile.currentStreak)", label: "Day streak", tint: Theme.primary, icon: "flame.fill")
            StatChip(value: "\(profile.totalXP)", label: "Total XP", tint: Theme.energy, icon: "bolt.fill")
            StatChip(value: "\(profile.sessions.count)", label: "Sessions", tint: Theme.info, icon: "figure.basketball")
        }
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

    private var dailyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Daily Challenge")
            Button {
                Haptics.tap()
                if let mode = TrainingModeCatalog.mode(id: challenge.modeID) { launch(mode) }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: challenge.icon)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color(hex: 0x0B0B0F))
                        .frame(width: 50, height: 50)
                        .background(challenge.tint, in: .circle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(challenge.detail)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer(minLength: 0)
                    VStack(spacing: 2) {
                        Text("+\(challenge.xp)").font(.headline.weight(.heavy)).foregroundStyle(challenge.tint)
                        Text("XP").font(.caption2.weight(.bold)).foregroundStyle(Theme.textSecondary)
                    }
                }
                .glassCard()
            }
            .buttonStyle(.plain)
        }
    }

    private var quickModes: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Training Modes")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(TrainingModeCatalog.all) { mode in
                    Button {
                        Haptics.tap()
                        launch(mode)
                    } label: {
                        ModeTile(mode: mode)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ModeTile: View {
    let mode: TrainingMode
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: mode.icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(mode.tint)
                .frame(width: 46, height: 46)
                .background(mode.tint.opacity(0.15), in: .rect(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(mode.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                Text(mode.tagline)
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .padding(16)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusL))
        .overlay(RoundedRectangle(cornerRadius: Theme.radiusL).strokeBorder(Theme.stroke, lineWidth: 1))
    }
}
