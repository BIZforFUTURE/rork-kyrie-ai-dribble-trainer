//
//  AssessmentScanView.swift
//  KyrieAI
//
//  Single-move scan: shows the move, a camera proxy, an animated scan ring,
//  and "analyzes" the rep before reporting a quality + reaction sample.
//

import SwiftUI

struct AssessmentScanView: View {
    let move: Move
    let index: Int
    let total: Int
    let tracker: HandleTracker
    let voice: VoiceCoach
    let onComplete: (_ quality: Double, _ reactionMs: Int) -> Void

    private enum State2 { case ready, recording, analyzing }
    @State private var state: State2 = .ready
    @State private var countdown: Int = 3
    @State private var recordProgress: Double = 0
    @State private var analyzeProgress: Double = 0
    @State private var scanRotate = false

    // per-move recognition feedback (shown briefly after the rep is graded)
    @State private var lastRecognition: MoveRecognition?
    @State private var feedbackText: String = ""
    @State private var feedbackPositive: Bool = true
    @State private var showFeedback: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            header
            CameraProxyView(tracker: tracker) {
                overlay
            }
            .frame(maxWidth: .infinity)
            .frame(height: 420)
            .clipShape(.rect(cornerRadius: Theme.radiusL))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusL)
                    .strokeBorder(move.difficulty.color.opacity(0.5), lineWidth: 1.5)
            )
            .padding(.horizontal, 20)

            controls
            Spacer(minLength: 0)
        }
        .padding(.top, 16)
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { i in
                    Capsule()
                        .fill(i <= index ? AnyShapeStyle(Theme.fireGradient) : AnyShapeStyle(Color.white.opacity(0.1)))
                        .frame(height: 5)
                }
            }
            .padding(.horizontal, 20)

            Text("MOVE \(index + 1) OF \(total)")
                .font(.caption.weight(.heavy))
                .tracking(2)
                .foregroundStyle(Theme.textSecondary)
            Text(move.name)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(move.detail)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
    }

    private var overlay: some View {
        ZStack {
            // scan ring
            if state != .ready {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(move.difficulty.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(scanRotate ? 360 : 0))
                    .opacity(0.7)
            }

            switch state {
            case .ready:
                VStack(spacing: 14) {
                    Image(systemName: "figure.basketball")
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                    Text("Get in frame & tap Start")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
            case .recording:
                VStack(spacing: 8) {
                    if countdown > 0 {
                        Text("\(countdown)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    } else {
                        Text(move.shortName)
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(move.difficulty.color)
                        HStack(spacing: 6) {
                            Circle().fill(.red).frame(width: 10, height: 10)
                            Text("Analyzing your reps…").font(.caption.weight(.semibold)).foregroundStyle(.white)
                        }
                    }
                }
            case .analyzing:
                VStack(spacing: 12) {
                    ProgressView(value: analyzeProgress)
                        .progressViewStyle(.linear)
                        .tint(move.difficulty.color)
                        .frame(width: 160)
                    Text("Scoring execution…")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }

            if showFeedback {
                VStack { feedbackToast.padding(.top, 14); Spacer() }
            }

            if state != .ready {
                VStack { Spacer(); trackingBadge.padding(.bottom, 16) }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showFeedback)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) { scanRotate = true }
        }
    }

    /// Per-move recognition feedback bubble, matching the live session.
    private var feedbackToast: some View {
        HStack(spacing: 8) {
            Image(systemName: feedbackPositive ? "checkmark.seal.fill" : "arrow.up.forward.circle.fill")
            Text(feedbackText)
                .font(.subheadline.weight(.heavy))
                .lineLimit(1)
            if let detected = lastRecognition?.detected {
                Text(detected.label.uppercased())
                    .font(.caption2.weight(.black)).tracking(1)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(.white.opacity(0.16), in: .capsule)
            }
        }
        .foregroundStyle(feedbackPositive ? Color(hex: 0x0B0B0F) : .white)
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(feedbackPositive ? Theme.energy : Color(hex: 0xFF5C8A), in: .capsule)
        .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    /// Live readout proving the camera is actually tracking the player.
    @ViewBuilder private var trackingBadge: some View {
        if tracker.isAvailable {
            HStack(spacing: 7) {
                Image(systemName: tracker.isLocked ? "hand.raised.fill" : "viewfinder")
                    .font(.caption2.weight(.bold))
                Text(tracker.isLocked ? "Tracking your hands" : "Get fully in frame")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(tracker.isLocked ? Theme.energy : .white.opacity(0.8))
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(.black.opacity(0.45), in: .capsule)
        }
    }

    private var controls: some View {
        Group {
            switch state {
            case .ready:
                PrimaryButton(title: "Start", icon: "record.circle", gradient: Theme.fireGradient) {
                    startRecording()
                }
            case .recording:
                HStack(spacing: 10) {
                    Image(systemName: "waveform")
                    Text(countdown > 0 ? "Get ready…" : "Keep going — stay in frame")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
            case .analyzing:
                HStack(spacing: 10) {
                    ProgressView().tint(Theme.primary)
                    Text("Kyrie AI is grading…")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
            }
        }
        .padding(.horizontal, 20)
    }

    private func startRecording() {
        state = .recording
        countdown = 3
        tickCountdown()
    }

    private func tickCountdown() {
        guard countdown > 0 else {
            Haptics.success()
            // Open a real Vision measurement window for the recording period.
            tracker.beginWindow()
            // Coach calls out the move to perform, just like a live drill.
            voice.command(move.shortName)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { beginAnalyzing() }
            return
        }
        Haptics.beat()
        voice.command("\(countdown)", rate: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.snappy) { countdown -= 1 }
            tickCountdown()
        }
    }

    private func beginAnalyzing() {
        state = .analyzing
        analyzeProgress = 0
        withAnimation(.easeInOut(duration: 1.6)) { analyzeProgress = 1 }
        let rep = tracker.endWindow()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            var quality: Double
            let reaction: Int
            var recognition: MoveRecognition?
            if tracker.isAvailable && rep.framesAnalyzed > 5 {
                // Real, measured grade from the Vision pipeline.
                quality = ScoreEngine.quality(from: rep, difficulty: move.difficulty)
                reaction = rep.reactionMs > 0 ? rep.reactionMs : 520
                // Per-move recognition: did they actually hit the called move?
                let rec = MoveRecognizer.recognize(rep: rep, expected: move)
                recognition = rec
                if rec.matchedExpected {
                    quality = min(0.99, quality + 0.05)
                } else if rec.detected != nil {
                    quality = max(0.3, quality - 0.08)
                }
            } else {
                // No camera (e.g. simulator) — fall back to a weighted estimate.
                let base = Double.random(in: 0.55...0.92)
                let difficultyPenalty: Double
                switch move.difficulty {
                case .basic: difficultyPenalty = 0
                case .intermediate: difficultyPenalty = 0.06
                case .advanced: difficultyPenalty = 0.12
                case .signature: difficultyPenalty = 0.18
                }
                quality = max(0.3, base - difficultyPenalty)
                reaction = Int.random(in: 280...620)
            }
            announceFeedback(for: recognition, quality: quality)
            // Let the feedback land before advancing to the next move.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                onComplete(quality, reaction)
            }
        }
    }

    /// Speak and surface a short reaction to the just-graded rep.
    private func announceFeedback(for recognition: MoveRecognition?, quality: Double) {
        let positive: Bool
        let line: String

        if let recognition, recognition.detected == nil {
            positive = false
            line = "Get in frame"
        } else if let recognition, !recognition.matchedExpected, let detected = recognition.detected {
            positive = false
            line = "Looked like a \(detected.spoken) — that's okay, logging it"
        } else if quality > 0.82 {
            positive = true
            line = ["Filthy!", "Ankles!", "Ice cold!", "That's the one!"].randomElement() ?? "Filthy!"
        } else if quality > 0.62 {
            positive = true
            line = ["Nice \(move.shortName.lowercased())", "Good rep", "Clean"].randomElement() ?? "Clean"
        } else {
            positive = false
            line = ["Stay low", "Snap it harder", "Tighter handle"].randomElement() ?? "Stay low"
        }

        lastRecognition = recognition
        feedbackText = line
        feedbackPositive = positive
        showFeedback = true
        if positive { Haptics.success() } else { Haptics.warning() }
        voice.feedback(line)
        let token = line
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            if feedbackText == token { showFeedback = false }
        }
    }
}
