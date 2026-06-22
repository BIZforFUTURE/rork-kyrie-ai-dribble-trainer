//
//  Move.swift
//  KyrieAI
//
//  Dribble move definitions used by assessment, sessions, and callouts.
//

import SwiftUI

nonisolated enum MoveDifficulty: String, Codable {
    case basic = "Basic"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case signature = "Signature"

    var color: Color {
        switch self {
        case .basic: return Theme.info
        case .intermediate: return Theme.energy
        case .advanced: return Theme.primary
        case .signature: return Color(hex: 0xB06BFF)
        }
    }
}

nonisolated struct Move: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let shortName: String        // used for big callouts
    let detail: String
    let difficulty: MoveDifficulty
    let primarySkills: [SkillCategory]

    static func == (lhs: Move, rhs: Move) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// Static catalog of trainable moves.
nonisolated enum MoveCatalog {
    static let all: [Move] = [
        Move(id: "pound", name: "Pound Dribble", shortName: "POUND", detail: "Hard low control dribble, fingertip command.", difficulty: .basic, primarySkills: [.control]),
        Move(id: "crossover", name: "Crossover", shortName: "CROSS", detail: "Snap the ball low across your body.", difficulty: .basic, primarySkills: [.control, .speed]),
        Move(id: "btl", name: "Between the Legs", shortName: "BTL", detail: "Thread it through with rhythm.", difficulty: .intermediate, primarySkills: [.coordination, .control]),
        Move(id: "btb", name: "Behind the Back", shortName: "BEHIND", detail: "Wrap it tight around your hip.", difficulty: .intermediate, primarySkills: [.coordination, .creativity]),
        Move(id: "hesi", name: "Hesitation", shortName: "HESI", detail: "Sell the stop, explode through.", difficulty: .intermediate, primarySkills: [.reaction, .speed]),
        Move(id: "inout", name: "In & Out", shortName: "IN-OUT", detail: "Fake the cross, keep it same hand.", difficulty: .intermediate, primarySkills: [.control, .creativity]),
        Move(id: "changepace", name: "Change of Pace", shortName: "CHANGE", detail: "Slow then burst — break the defender.", difficulty: .intermediate, primarySkills: [.speed, .reaction]),
        Move(id: "doublecross", name: "Double-Cross Pocket", shortName: "DOUBLE-CROSS POCKET", detail: "Cross, cross back, attack.", difficulty: .advanced, primarySkills: [.coordination, .speed]),
        Move(id: "shamgod", name: "Shamgod", shortName: "SHAMGOD", detail: "Push out, pull back with the off hand.", difficulty: .advanced, primarySkills: [.creativity, .coordination]),
        Move(id: "kyriecombo", name: "Kyrie Combo", shortName: "BETWEEN THE LEGS BEHIND THE BACK", detail: "Between-legs into behind-back finish.", difficulty: .signature, primarySkills: [.creativity, .coordination, .control]),
        Move(id: "weakpound", name: "Weak-Hand Pound", shortName: "WEAK", detail: "Off hand only — build that command.", difficulty: .basic, primarySkills: [.weakHand, .control]),
        Move(id: "spin", name: "Spin Move", shortName: "SPIN", detail: "Plant, spin, protect the ball.", difficulty: .advanced, primarySkills: [.coordination, .creativity]),
        Move(id: "snatchback", name: "Snatch Back", shortName: "SNATCH", detail: "Drive then rip it back for space.", difficulty: .advanced, primarySkills: [.reaction, .creativity]),
    ]

    static func move(id: String) -> Move? { all.first { $0.id == id } }

    static let assessmentMoves: [Move] = [
        move(id: "pound")!,
        move(id: "crossover")!,
        move(id: "btl")!,
        move(id: "btb")!,
        move(id: "hesi")!,
        move(id: "changepace")!,
    ]
}
