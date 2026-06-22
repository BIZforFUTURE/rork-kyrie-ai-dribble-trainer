//
//  MoveRecognizer.swift
//  KyrieAI
//
//  Turns a measured Vision rep window into a best-guess dribble move. Each
//  trainable move maps to a recognizable motion "pattern" (lateral switch,
//  low pass-through, pause-and-burst, etc.). The recognizer compares what the
//  camera actually saw against the move Kyrie called out, so the app can tell
//  the player whether they hit the right move and grade it honestly.
//

import Foundation

/// A coarse motion signature that several named moves can share.
nonisolated enum MovePattern: String {
    case pound
    case crossover
    case betweenLegs
    case behindBack
    case hesitation
    case combo

    /// Natural phrasing the voice coach speaks aloud.
    var spoken: String {
        switch self {
        case .pound: return "pound dribble"
        case .crossover: return "crossover"
        case .betweenLegs: return "between the legs"
        case .behindBack: return "behind the back"
        case .hesitation: return "hesitation"
        case .combo: return "combo"
        }
    }

    /// Short label for on-screen badges.
    var label: String {
        switch self {
        case .pound: return "Pound"
        case .crossover: return "Crossover"
        case .betweenLegs: return "Between Legs"
        case .behindBack: return "Behind Back"
        case .hesitation: return "Hesitation"
        case .combo: return "Combo"
        }
    }
}

/// Result of comparing a measured rep to the move that was called.
nonisolated struct MoveRecognition {
    /// Best-guess pattern the camera saw (nil when the player wasn't tracked).
    let detected: MovePattern?
    /// Whether the detected pattern matches the called move.
    let matchedExpected: Bool
    /// Confidence in the recognition, 0...1.
    let confidence: Double
}

nonisolated enum MoveRecognizer {
    /// The motion signature each catalog move is expected to produce.
    static func expectedPattern(for move: Move) -> MovePattern {
        switch move.id {
        case "pound", "weakpound": return .pound
        case "crossover", "doublecross", "inout", "shamgod": return .crossover
        case "btl": return .betweenLegs
        case "btb", "spin": return .behindBack
        case "hesi", "changepace", "snatchback": return .hesitation
        case "kyriecombo": return .combo
        default: return .crossover
        }
    }

    /// Classify a measured rep window into its most likely move pattern.
    private static func classify(_ rep: HandleRepResult) -> (pattern: MovePattern?, confidence: Double) {
        guard rep.detectionRate > 0.25, rep.framesAnalyzed > 3 else { return (nil, 0) }

        let lowPassThrough = rep.maxLowness > 0.62      // ball dropped near the floor
        let manySwitches = rep.crossovers >= 2
        let oneSwitch = rep.crossovers >= 1
        let active = rep.avgMotion > 0.018
        let hesitation = rep.hesitationEvents >= 1

        // Multiple side-switches plus a deep pass-through reads as a combo.
        if manySwitches && lowPassThrough {
            return (.combo, 0.72)
        }
        // A side-switch that dips very low is a between-the-legs.
        if oneSwitch && lowPassThrough {
            return (.betweenLegs, 0.74)
        }
        // A side-switch that stays high reads as behind-the-back.
        if oneSwitch && rep.avgLowness < 0.35 {
            return (.behindBack, 0.62)
        }
        // A clean lateral switch at mid height is a crossover.
        if oneSwitch {
            return (.crossover, 0.76)
        }
        // No switch, but a clear pause-and-burst is a hesitation.
        if hesitation {
            return (.hesitation, 0.66)
        }
        // Steady up-and-down activity with no switch is a pound dribble.
        if active {
            return (.pound, 0.6)
        }
        return (nil, 0.3)
    }

    /// Compare what was measured against the called move.
    static func recognize(rep: HandleRepResult, expected: Move) -> MoveRecognition {
        let target = expectedPattern(for: expected)
        let (detected, confidence) = classify(rep)
        let matched = detected == target
        return MoveRecognition(
            detected: detected,
            matchedExpected: matched,
            confidence: matched ? max(confidence, 0.6) : confidence
        )
    }
}
