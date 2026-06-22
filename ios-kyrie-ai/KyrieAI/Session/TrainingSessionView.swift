//
//  TrainingSessionView.swift
//  KyrieAI
//
//  Live AI training session: camera proxy + big move callouts, reaction
//  targets, combo tracking, and real-time visual feedback.
//

import SwiftUI
import SwiftData

struct TrainingSessionView: View {
    let profile: PlayerProfile
    let mode: TrainingMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var vm: TrainingSessionViewModel

    init(profile: PlayerProfile, mode: TrainingMode) {
        self.profile = profile
        self.mode = mode
        _vm = State(initialValue: TrainingSessionViewModel(mode: mode))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraProxyView(tracker: vm.tracker) {
                LinearGradient(colors: [.black.opacity(0.2), .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()

            switch vm.phase {
            case .countdown: countdownOverlay
            case .active: activeOverlay
            case .finished:
                SessionResultView(profile: profile, mode: mode, vm: vm) {
                    commitSession()
                    dismiss()
                }
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: vm.showFeedback)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            vm.start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            vm.stop()
        }
    }

    // MARK: Countdown

    private var countdownOverlay: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(mode.title.uppercased())
                .font(.caption.weight(.heavy)).tracking(3)
                .foregroundStyle(mode.tint)
            Text(vm.countdown > 0 ? "\(vm.countdown)" : "GO")
                .font(.system(size: 130, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .shadow(color: mode.tint.opacity(0.6), radius: 30)
            Text("Get the ball in your hands & step into frame")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            closeButton.padding(.bottom, 30)
        }
        .padding()
    }

    // MARK: Active

    private var activeOverlay: some View {
        VStack(spacing: 0) {
            // top HUD
            HStack {
                closeButton
                Spacer()
                VStack(spacing: 2) {
                    Text("\(vm.movesDone)/\(vm.totalMoves)")
                        .font(.headline.weight(.heavy)).foregroundStyle(.white)
                    Text("MOVES").font(.caption2.weight(.bold)).foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("x\(vm.comboCount)")
                        .font(.headline.weight(.heavy)).foregroundStyle(Theme.energy)
                    Text("COMBO").font(.caption2.weight(.bold)).foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                voiceButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // live Vision tracking status
            if vm.tracker.isAvailable {
                HStack(spacing: 7) {
                    Image(systemName: vm.tracker.isLocked ? "hand.raised.fill" : "viewfinder")
                        .font(.caption2.weight(.bold))
                    Text(vm.tracker.isLocked ? "Tracking" : "Step into frame")
                        .font(.caption2.weight(.bold))
                    if vm.tracker.isLocked {
                        TrackingMotionBar(level: vm.tracker.motionLevel, tint: mode.tint)
                    }
                }
                .foregroundStyle(vm.tracker.isLocked ? Theme.energy : .white.opacity(0.75))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(.black.opacity(0.4), in: .capsule)
                .padding(.top, 10)
            }

            // progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12))
                    Capsule().fill(mode.tint)
                        .frame(width: geo.size.width * CGFloat(vm.movesDone) / CGFloat(max(1, vm.totalMoves)))
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            // per-move quality feedback toast
            if vm.showFeedback {
                HStack(spacing: 8) {
                    Image(systemName: vm.feedbackPositive ? "checkmark.seal.fill" : "arrow.up.forward.circle.fill")
                    Text(vm.feedbackText)
                        .font(.subheadline.weight(.heavy))
                        .lineLimit(1)
                }
                .foregroundStyle(vm.feedbackPositive ? Color(hex: 0x0B0B0F) : .white)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(vm.feedbackPositive ? Theme.energy : Color(hex: 0xFF5C8A), in: .capsule)
                .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
                .padding(.top, 14)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer().frame(height: 4)

            // big callout
            if let move = vm.currentMove {
                VStack(spacing: 18) {
                    TimerRing(remaining: vm.timeRemaining, total: vm.moveDuration, tint: mode.tint)
                    Text(move.shortName)
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: mode.tint.opacity(0.7), radius: 20)
                        .id(move.id)
                        .transition(.scale.combined(with: .opacity))
                    Text(move.detail)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: move.id)
            }

            Spacer()

            // hit confirm button
            Button {
                vm.registerHit()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Nailed it").fontWeight(.bold)
                }
                .font(.headline)
                .foregroundStyle(Color(hex: 0x0B0B0F))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(mode.tint, in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }

    private var voiceButton: some View {
        Button {
            vm.voice.isEnabled.toggle()
            if vm.voice.isEnabled { vm.voice.command("Coach on") }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            Image(systemName: vm.voice.isEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.headline.weight(.bold))
                .foregroundStyle(vm.voice.isEnabled ? Theme.energy : .white.opacity(0.7))
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.12), in: .circle)
        }
        .buttonStyle(.plain)
    }

    private var closeButton: some View {
        Button {
            vm.stop()
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.12), in: .circle)
        }
        .buttonStyle(.plain)
    }

    private func commitSession() {
        let record = SessionRecord(
            modeID: mode.id,
            modeTitle: mode.title,
            durationSeconds: max(60, vm.totalMoves * vm.moveDuration),
            movesCompleted: vm.samples.count,
            accuracy: vm.resultAccuracy,
            avgReactionMs: vm.resultReactionMs,
            xpEarned: vm.resultXP
        )
        record.id = UUID()
        profile.sessions.append(record)
        profile.totalXP += vm.resultXP

        // update streak
        updateStreak()

        // nudge category scores upward based on performance
        let gain = vm.resultAccuracy >= 75 ? 2 : 1
        for cat in mode.focus {
            profile.setScore(profile.score(for: cat) + gain, for: cat)
        }
        // recompute overall score
        var cats: [SkillCategory: Int] = [:]
        for cat in SkillCategory.allCases { cats[cat] = profile.score(for: cat) }
        profile.ballHandlerScore = ScoreEngine.ballHandlerScore(from: cats)

        try? modelContext.save()
        StreakWidgetSync.sync(from: profile)
    }

    private func updateStreak() {
        let cal = Calendar.current
        if let last = profile.lastTrainedAt {
            if cal.isDateInToday(last) {
                // already trained today, keep streak
            } else if cal.isDateInYesterday(last) {
                profile.currentStreak += 1
            } else {
                profile.currentStreak = 1
            }
        } else {
            profile.currentStreak = 1
        }
        profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
        profile.lastTrainedAt = Date()
    }
}

// MARK: - Live motion bar

/// Small animated bar showing real-time hand motion measured by Vision.
struct TrackingMotionBar: View {
    let level: Double
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.18))
                Capsule().fill(tint)
                    .frame(width: geo.size.width * CGFloat(max(0.05, min(1, level))))
            }
        }
        .frame(width: 44, height: 5)
        .animation(.easeOut(duration: 0.15), value: level)
    }
}

// MARK: - Timer ring

struct TimerRing: View {
    let remaining: Int
    let total: Int
    let tint: Color

    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.15), lineWidth: 6)
                .frame(width: 90, height: 90)
            Circle()
                .trim(from: 0, to: CGFloat(remaining) / CGFloat(max(1, total)))
                .stroke(tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 90, height: 90)
                .animation(.linear(duration: 1), value: remaining)
            Text("\(remaining)")
                .font(.title.weight(.heavy))
                .foregroundStyle(.white)
        }
    }
}
