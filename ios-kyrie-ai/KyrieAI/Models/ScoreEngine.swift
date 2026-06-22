//
//  ScoreEngine.swift
//  KyrieAI
//
//  Lightweight "AI" model that turns raw drill performance into category
//  scores and an overall Ball Handler Score.
//

import Foundation

nonisolated struct DrillSample {
    let move: Move
    /// 0...1 quality the camera/coach perceived for this rep set.
    let quality: Double
    /// reaction in ms (lower is better) — relevant for reaction moves.
    let reactionMs: Int
}

nonisolated enum ScoreEngine {
    /// Derive category scores (0...100) from assessment samples + the player's
    /// declared skill level baseline.
    static func categoryScores(from samples: [DrillSample], baseline: Int) -> [SkillCategory: Int] {
        var totals: [SkillCategory: Double] = [:]
        var counts: [SkillCategory: Double] = [:]

        for sample in samples {
            for skill in sample.move.primarySkills {
                totals[skill, default: 0] += sample.quality
                counts[skill, default: 0] += 1
            }
        }

        var result: [SkillCategory: Int] = [:]
        for category in SkillCategory.allCases {
            let avg = counts[category].map { totals[category]! / $0 } ?? 0.55
            // blend declared baseline with measured performance
            let measured = avg * 100
            let blended = Double(baseline) * 0.45 + measured * 0.55
            // small per-category variance so the radar looks alive
            let jitter = Double((category.rawValue.count * 7) % 9) - 4
            result[category] = max(20, min(99, Int(blended + jitter)))
        }
        return result
    }

    static func ballHandlerScore(from categories: [SkillCategory: Int]) -> Int {
        guard !categories.isEmpty else { return 0 }
        let weights: [SkillCategory: Double] = [
            .control: 1.3, .speed: 1.0, .coordination: 1.1,
            .reaction: 1.0, .creativity: 0.9, .weakHand: 1.05
        ]
        var weighted = 0.0
        var weightSum = 0.0
        for (cat, score) in categories {
            let w = weights[cat] ?? 1
            weighted += Double(score) * w
            weightSum += w
        }
        return Int((weighted / weightSum).rounded())
    }

    /// Convert a real Vision measurement of one rep window into a 0...1 quality.
    /// Blends how clearly the hands were tracked, how active the dribbling was,
    /// and how low/controlled the handle stayed, then weighs by difficulty.
    static func quality(from rep: HandleRepResult, difficulty: MoveDifficulty) -> Double {
        let detection = min(1, rep.detectionRate / 0.8)      // ~80% visibility = full marks
        let motion = min(1, rep.avgMotion / 0.05)            // active, committed dribbling
        let lowness = min(1, rep.avgLowness / 0.55)          // low, protected handle
        var quality = detection * 0.4 + motion * 0.35 + lowness * 0.25

        // Harder moves are graded a touch tougher.
        let penalty: Double
        switch difficulty {
        case .basic: penalty = 0
        case .intermediate: penalty = 0.04
        case .advanced: penalty = 0.08
        case .signature: penalty = 0.12
        }
        quality -= penalty
        return max(0.3, min(0.99, quality))
    }

    /// Score one completed live session into accuracy / reaction / xp.
    static func gradeSession(samples: [DrillSample], mode: TrainingMode) -> (accuracy: Int, avgReactionMs: Int, xp: Int) {
        guard !samples.isEmpty else { return (0, 0, 0) }
        let avgQuality = samples.map(\.quality).reduce(0, +) / Double(samples.count)
        let accuracy = max(35, min(99, Int(avgQuality * 100)))
        let avgReaction = samples.map(\.reactionMs).reduce(0, +) / samples.count
        let baseXP = mode.defaultReps * 10
        let bonus = Int(avgQuality * 80)
        return (accuracy, avgReaction, baseXP + bonus)
    }
}
