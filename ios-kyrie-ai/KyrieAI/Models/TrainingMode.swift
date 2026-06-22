//
//  TrainingMode.swift
//  KyrieAI
//
//  Specialized training modes and their session blueprints.
//

import SwiftUI

nonisolated struct TrainingMode: Identifiable {
    let id: String
    let title: String
    let tagline: String
    let icon: String
    let tint: Color
    let focus: [SkillCategory]
    /// Move ids drawn on for this mode's callout sequence.
    let moveIDs: [String]
    let defaultReps: Int

    var moves: [Move] { moveIDs.compactMap { MoveCatalog.move(id: $0) } }
}

nonisolated enum TrainingModeCatalog {
    static let all: [TrainingMode] = [
        TrainingMode(
            id: "handlelab",
            title: "Handle Lab",
            tagline: "Tighten control with relentless reps",
            icon: "scope",
            tint: Theme.primary,
            focus: [.control, .coordination],
            moveIDs: ["pound", "crossover", "btl", "btb", "inout", "doublecross"],
            defaultReps: 12
        ),
        TrainingMode(
            id: "reaction",
            title: "Reaction Training",
            tagline: "Beat the buzzer — train your trigger",
            icon: "timer",
            tint: Color(hex: 0xFF5C8A),
            focus: [.reaction, .speed],
            moveIDs: ["crossover", "hesi", "changepace", "snatchback", "inout"],
            defaultReps: 14
        ),
        TrainingMode(
            id: "gamemoves",
            title: "Game Moves",
            tagline: "Counters that break real defenders",
            icon: "figure.basketball",
            tint: Theme.energy,
            focus: [.creativity, .speed, .control],
            moveIDs: ["hesi", "changepace", "snatchback", "spin", "kyriecombo"],
            defaultReps: 10
        ),
        TrainingMode(
            id: "weakhand",
            title: "Weak Hand Development",
            tagline: "Make your off hand a weapon",
            icon: "hand.point.left.fill",
            tint: Theme.info,
            focus: [.weakHand, .control],
            moveIDs: ["weakpound", "crossover", "btl", "inout"],
            defaultReps: 14
        ),
        TrainingMode(
            id: "courtvision",
            title: "Court Vision",
            tagline: "Handle while reading visual cues",
            icon: "eye.fill",
            tint: Color(hex: 0xB06BFF),
            focus: [.reaction, .coordination],
            moveIDs: ["pound", "crossover", "btl", "hesi", "changepace"],
            defaultReps: 12
        ),
        TrainingMode(
            id: "signature",
            title: "Kyrie Signature Lab",
            tagline: "Master elite creative sequences",
            icon: "sparkles",
            tint: Color(hex: 0xFFC53D),
            focus: [.creativity, .coordination, .control],
            moveIDs: ["kyriecombo", "shamgod", "spin", "doublecross", "snatchback"],
            defaultReps: 8
        ),
    ]

    static func mode(id: String) -> TrainingMode? { all.first { $0.id == id } }

    /// The workout assigned to a given date for a player, rotating daily through the
    /// modes that target their weakest skills. Used by both Today's Plan and the
    /// full weekly plan so they always agree.
    static func mode(for date: Date, weakest: [SkillCategory]) -> TrainingMode {
        let weak = Set(weakest)
        let matching = all.filter { !Set($0.focus).isDisjoint(with: weak) }
        let pool = matching.isEmpty ? all : matching
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return pool[day % pool.count]
    }
}

nonisolated struct DailyChallenge: Identifiable {
    let id: String
    let title: String
    let detail: String
    let icon: String
    let tint: Color
    let xp: Int
    let modeID: String
}

nonisolated enum ChallengeFactory {
    /// Deterministic daily challenge based on the day of year.
    static func today() -> DailyChallenge {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let pool: [DailyChallenge] = [
            DailyChallenge(id: "c1", title: "60-Second Crossover Storm", detail: "Max clean crossovers in one minute.", icon: "bolt.fill", tint: Theme.primary, xp: 120, modeID: "handlelab"),
            DailyChallenge(id: "c2", title: "Weak Hand Gauntlet", detail: "Off-hand only — no fumbles allowed.", icon: "hand.point.left.fill", tint: Theme.info, xp: 150, modeID: "weakhand"),
            DailyChallenge(id: "c3", title: "Reaction Buzzer", detail: "React to 14 random callouts.", icon: "timer", tint: Color(hex: 0xFF5C8A), xp: 140, modeID: "reaction"),
            DailyChallenge(id: "c4", title: "Signature Flow", detail: "Chain 8 Kyrie-style combos.", icon: "sparkles", tint: Color(hex: 0xFFC53D), xp: 200, modeID: "signature"),
            DailyChallenge(id: "c5", title: "Game Move Counters", detail: "Read and counter every defender cue.", icon: "figure.basketball", tint: Theme.energy, xp: 160, modeID: "gamemoves"),
        ]
        return pool[day % pool.count]
    }
}
