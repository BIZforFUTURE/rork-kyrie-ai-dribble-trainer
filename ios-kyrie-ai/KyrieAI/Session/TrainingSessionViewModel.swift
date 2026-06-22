//
//  TrainingSessionViewModel.swift
//  KyrieAI
//
//  Drives the live training session: emits move callouts on a timer,
//  collects perceived performance, and grades the result.
//

import SwiftUI
import Combine

@Observable
@MainActor
final class TrainingSessionViewModel {
    let mode: TrainingMode

    enum Phase { case countdown, active, finished }
    var phase: Phase = .countdown
    var countdown: Int = 3

    var currentMove: Move?
    var movesDone: Int = 0
    var totalMoves: Int
    var timeRemaining: Int = 0          // seconds for current move
    var moveDuration: Int = 4

    // running performance
    private(set) var samples: [DrillSample] = []
    var lastReactionMs: Int = 0
    var comboCount: Int = 0
    var perceivedQuality: Double = 0.8

    // grading result
    var resultAccuracy: Int = 0
    var resultReactionMs: Int = 0
    var resultXP: Int = 0

    // per-move recognition feedback (transient, shown after each rep)
    var lastRecognition: MoveRecognition?
    var feedbackText: String = ""
    var feedbackPositive: Bool = true
    var showFeedback: Bool = false

    private var timer: Timer?
    private var moveTimer: Timer?

    /// Live Vision tracker shared with the camera preview.
    let tracker = HandleTracker()

    /// On-device voice that calls out moves and reacts to reps.
    let voice = VoiceCoach()

    init(mode: TrainingMode) {
        self.mode = mode
        self.totalMoves = mode.defaultReps
    }

    func start() {
        tracker.startSession()
        phase = .countdown
        countdown = 3
        tickCountdown()
    }

    private func tickCountdown() {
        Haptics.beat()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            Task { @MainActor in
                guard let self else { return }
                self.countdown -= 1
                if self.countdown <= 0 {
                    t.invalidate()
                    Haptics.success()
                    self.voice.command("Let's go!")
                    self.beginActive()
                } else {
                    Haptics.beat()
                    self.voice.command("\(self.countdown)", rate: 0.5)
                }
            }
        }
    }

    private func beginActive() {
        phase = .active
        movesDone = 0
        nextMove()
        moveTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.phase == .active else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.commitCurrentMove()
                }
            }
        }
    }

    private func nextMove() {
        guard movesDone < totalMoves else { finish(); return }
        // duration shrinks slightly as the session ramps up
        moveDuration = max(2, 4 - movesDone / 5)
        timeRemaining = moveDuration
        let move = mode.moves.randomElement()
        currentMove = move
        // Open a fresh Vision measurement window for this callout.
        tracker.beginWindow()
        Haptics.heavy()
        // Coach barks the move name (queues behind any rep feedback).
        if let move { voice.command(move.shortName) }
    }

    /// Player tapped to confirm they hit the move cleanly (boosts quality).
    func registerHit() {
        comboCount += 1
        perceivedQuality = min(1, perceivedQuality + 0.03)
        // Build intensity: every 5th combo earns a stronger thump.
        if comboCount % 5 == 0 { Haptics.heavy() } else { Haptics.beat() }
    }

    private func commitCurrentMove() {
        if let move = currentMove {
            let rep = tracker.endWindow()
            var quality: Double
            let reaction: Int
            if tracker.isAvailable && rep.framesAnalyzed > 3 {
                // Real measured grade from the camera.
                quality = ScoreEngine.quality(from: rep, difficulty: move.difficulty)
                reaction = rep.reactionMs > 0 ? rep.reactionMs : 520
                lastReactionMs = reaction
                // Per-move recognition: did they actually hit the called move?
                let recognition = MoveRecognizer.recognize(rep: rep, expected: move)
                lastRecognition = recognition
                // Reward a clean, correct move; nudge down a wrong one.
                if recognition.matchedExpected {
                    quality = min(0.99, quality + 0.05)
                } else if recognition.detected != nil {
                    quality = max(0.3, quality - 0.08)
                }
                announceFeedback(for: recognition, quality: quality, move: move)
            } else {
                // No camera (e.g. simulator) — fall back to the perceived estimate.
                quality = max(0.4, min(0.99, perceivedQuality + Double(comboCount) * 0.005 + Double.random(in: -0.08...0.08)))
                reaction = 0
                lastRecognition = nil
                announceFeedback(for: nil, quality: quality, move: move)
            }
            samples.append(DrillSample(move: move, quality: quality, reactionMs: reaction))
            // Every completed exercise extends the combo and plays a reward cue.
            comboCount += 1
            SoundFX.repSuccess()
        }
        movesDone += 1
        if movesDone >= totalMoves {
            finish()
        } else {
            nextMove()
        }
    }

    /// Build and speak a short reaction to the just-completed rep, and surface
    /// the same line on screen briefly. Only uses quality-based feedback — no
    /// move-guessing, since Vision-based move classification is heuristic.
    private func announceFeedback(for recognition: MoveRecognition?, quality: Double, move: Move) {
        let positive: Bool
        let line: String

        if quality > 0.82 {
            positive = true
            line = ["Filthy!", "Ankles!", "Ice cold!", "That's the one!", "Unreal handle!"].randomElement() ?? "Filthy!"
        } else if quality > 0.62 {
            positive = true
            line = ["Good rep", "Clean", "Keep that rhythm", "Nice work"].randomElement() ?? "Good rep"
        } else {
            positive = false
            line = "Next rep"
        }

        feedbackText = line
        feedbackPositive = positive
        showFeedback = true
        if positive { Haptics.success() } else { Haptics.tap() }
        voice.feedback(line)
        let token = line
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.4))
            if self.feedbackText == token { self.showFeedback = false }
        }
    }

    private func finish() {
        moveTimer?.invalidate(); moveTimer = nil
        timer?.invalidate(); timer = nil
        phase = .finished
        let graded = ScoreEngine.gradeSession(samples: samples, mode: mode)
        resultAccuracy = graded.accuracy
        resultReactionMs = graded.avgReactionMs
        resultXP = graded.xp
        Haptics.success()
        let closer = graded.accuracy >= 80 ? "Session complete. Elite work today."
            : graded.accuracy >= 60 ? "Session complete. Solid work — keep grinding."
            : "Session complete. Trust the reps, we go again."
        voice.command(closer, rate: 0.52)
    }

    func stop() {
        moveTimer?.invalidate(); moveTimer = nil
        timer?.invalidate(); timer = nil
        tracker.stopSession()
        voice.stop()
    }

    var elapsedSeconds: Int {
        // approximate from moves done * avg duration
        samples.count * moveDuration
    }
}
