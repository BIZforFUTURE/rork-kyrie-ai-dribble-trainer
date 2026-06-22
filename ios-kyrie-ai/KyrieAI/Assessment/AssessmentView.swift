//
//  AssessmentView.swift
//  KyrieAI
//
//  AI skill assessment: the player performs core moves while the camera
//  "analyzes" them, producing category scores + a Ball Handler Score.
//

import SwiftUI
import SwiftData

struct AssessmentView: View {
    let profile: PlayerProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(StoreViewModel.self) private var store

    private enum Phase { case intro, scanning, building, result }
    @State private var phase: Phase = .intro
    @State private var moveIndex: Int = 0
    @State private var samples: [DrillSample] = []
    @State private var computedCategories: [SkillCategory: Int] = [:]
    @State private var computedScore: Int = 0
    @State private var tracker = HandleTracker()
    @State private var voice = VoiceCoach()
    /// Presented when a non-subscriber tries to start the assessment.
    @State private var showPaywall = false

    private let moves = MoveCatalog.assessmentMoves

    var body: some View {
        ZStack {
            ArenaBackground()
            switch phase {
            case .intro: intro
            case .scanning: scanning
            case .building:
                PlanBuildingView(profile: profile) {
                    phase = .result
                }
            case .result:
                AssessmentResultView(
                    profile: profile,
                    categories: computedCategories,
                    score: computedScore
                ) { commit() }
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: phase)
        .onAppear {
            tracker.startSession()
        }
        .onDisappear { tracker.stopSession(); voice.stop() }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(store: store, context: "Subscribe to unlock your AI skill assessment")
        }
        .onChange(of: store.isPremium) { _, isPremium in
            // If they subscribe from the gated paywall, kick off the assessment.
            if isPremium && showPaywall {
                showPaywall = false
                beginAssessment()
            }
        }
    }

    // MARK: Intro

    private var intro: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(Theme.primary.opacity(0.15)).frame(width: 200).blur(radius: 30)
                Image(systemName: "camera.metering.center.weighted")
                    .font(.system(size: 80))
                    .foregroundStyle(Theme.fireGradient)
            }
            voiceToggle
            VStack(spacing: 12) {
                Text("AI Skill Assessment")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text("Coach will call out \(moves.count) moves. Perform each one in front of your camera. Kyrie AI measures control, speed, coordination, reaction, and creativity to build your Ball Handler Score.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 28)
            }
            VStack(spacing: 10) {
                ForEach(moves) { move in
                    HStack(spacing: 12) {
                        Image(systemName: "figure.basketball")
                            .foregroundStyle(move.difficulty.color)
                        Text(move.name).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.textPrimary)
                        Spacer()
                        TagPill(text: move.difficulty.rawValue, color: move.difficulty.color)
                    }
                }
            }
            .glassCard()
            .padding(.horizontal, 22)
            Spacer()
            VStack(spacing: 12) {
                PrimaryButton(title: store.isPremium ? "Begin Assessment" : "Subscribe to Begin", icon: store.isPremium ? "play.fill" : "lock.fill") {
                    guard store.isPremium else {
                        Haptics.tap()
                        showPaywall = true
                        return
                    }
                    beginAssessment()
                }
                Button {
                    Haptics.light()
                    skipAssessment()
                } label: {
                    Text("Skip for now")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
        }
    }

    private func beginAssessment() {
        moveIndex = 0
        samples = []
        phase = .scanning
        voice.command("Let's see what you've got. First move coming up.", rate: 0.52)
    }

    // MARK: Scanning

    private var voiceToggle: some View {
        Button {
            voice.isEnabled.toggle()
            if voice.isEnabled { voice.command("Coach on") }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: voice.isEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                Text(voice.isEnabled ? "Coach Voice On" : "Coach Voice Off")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(voice.isEnabled ? Theme.energy : Theme.textSecondary)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(.white.opacity(0.08), in: .capsule)
        }
        .buttonStyle(.plain)
    }

    private var scanning: some View {
        AssessmentScanView(
            move: moves[moveIndex],
            index: moveIndex,
            total: moves.count,
            tracker: tracker,
            voice: voice
        ) { quality, reactionMs in
            samples.append(DrillSample(move: moves[moveIndex], quality: quality, reactionMs: reactionMs))
            if moveIndex + 1 < moves.count {
                moveIndex += 1
            } else {
                finishAssessment()
            }
        }
        .id(moveIndex)
    }

    private func finishAssessment() {
        let cats = ScoreEngine.categoryScores(from: samples, baseline: profile.skillLevel.baseScore)
        computedCategories = cats
        computedScore = ScoreEngine.ballHandlerScore(from: cats)
        voice.command("Great work. Building your custom plan now.", rate: 0.5)
        phase = .building
    }

    /// Skip the camera assessment and seed baseline scores from the chosen skill level.
    private func skipAssessment() {
        let base = profile.skillLevel.baseScore
        for cat in SkillCategory.allCases {
            profile.setScore(base, for: cat)
        }
        profile.ballHandlerScore = base
        finalize()
    }

    private func commit() {
        for cat in SkillCategory.allCases {
            profile.setScore(computedCategories[cat] ?? 50, for: cat)
        }
        profile.ballHandlerScore = computedScore
        finalize()
    }

    /// Persist completion so the router advances from the assessment into the main app.
    private func finalize() {
        profile.hasAssessment = true
        try? modelContext.save()
    }
}
