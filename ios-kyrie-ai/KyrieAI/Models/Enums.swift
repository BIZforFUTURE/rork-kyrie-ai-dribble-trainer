//
//  Enums.swift
//  KyrieAI
//
//  Core enumerations describing a player profile and training domain.
//

import SwiftUI

nonisolated enum SkillLevel: String, CaseIterable, Codable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case elite = "Elite"

    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .beginner: return "New to organized handles"
        case .intermediate: return "Solid fundamentals, building moves"
        case .advanced: return "Confident with combos & speed"
        case .elite: return "Tournament / collegiate level"
        }
    }
    var baseScore: Int {
        switch self {
        case .beginner: return 42
        case .intermediate: return 58
        case .advanced: return 72
        case .elite: return 85
        }
    }
}

nonisolated enum Position: String, CaseIterable, Codable, Identifiable {
    case pointGuard = "Point Guard"
    case shootingGuard = "Shooting Guard"
    case smallForward = "Small Forward"
    case powerForward = "Power Forward"
    case center = "Center"

    var id: String { rawValue }
    var short: String {
        switch self {
        case .pointGuard: return "PG"
        case .shootingGuard: return "SG"
        case .smallForward: return "SF"
        case .powerForward: return "PF"
        case .center: return "C"
        }
    }
}

nonisolated enum Hand: String, CaseIterable, Codable, Identifiable {
    case left = "Left"
    case right = "Right"
    var id: String { rawValue }
}

nonisolated enum TrainingGoal: String, CaseIterable, Codable, Identifiable {
    case tighterHandle = "Tighter Handle"
    case speed = "Explosive Speed"
    case weakHand = "Weak Hand"
    case creativity = "Creativity & Flair"
    case gameMoves = "Game Moves"
    case confidence = "Confidence"
    case footwork = "Footwork"
    case reaction = "Reaction Time"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .tighterHandle: return "hand.raised.fill"
        case .speed: return "bolt.fill"
        case .weakHand: return "hand.point.left.fill"
        case .creativity: return "sparkles"
        case .gameMoves: return "figure.basketball"
        case .confidence: return "flame.fill"
        case .footwork: return "shoeprints.fill"
        case .reaction: return "timer"
        }
    }
}

nonisolated enum Availability: String, CaseIterable, Codable, Identifiable {
    case casual = "2–3 days / week"
    case committed = "4–5 days / week"
    case daily = "Every day"
    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .casual: return "Steady progress"
        case .committed: return "Fast improvement"
        case .daily: return "Elite trajectory"
        }
    }

    /// Derives a weekly commitment tier from the number of selected training days.
    static func from(dayCount: Int) -> Availability {
        switch dayCount {
        case ...3: return .casual
        case 4...5: return .committed
        default: return .daily
        }
    }
}

/// Days of the week a player can commit to training.
nonisolated enum Weekday: String, CaseIterable, Codable, Identifiable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"

    var id: String { rawValue }
    /// Two-letter label for compact chips.
    var short: String {
        switch self {
        case .monday: return "Mo"
        case .tuesday: return "Tu"
        case .wednesday: return "We"
        case .thursday: return "Th"
        case .friday: return "Fr"
        case .saturday: return "Sa"
        case .sunday: return "Su"
        }
    }
    /// Ordering index for stable sorting (Mon = 0).
    var order: Int { Weekday.allCases.firstIndex(of: self) ?? 0 }
}

/// The dribbling skill categories scored across the app.
nonisolated enum SkillCategory: String, CaseIterable, Codable, Identifiable {
    case control = "Control"
    case speed = "Speed"
    case coordination = "Coordination"
    case reaction = "Reaction"
    case creativity = "Creativity"
    case weakHand = "Weak Hand"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .control: return "scope"
        case .speed: return "bolt.fill"
        case .coordination: return "figure.gymnastics"
        case .reaction: return "timer"
        case .creativity: return "sparkles"
        case .weakHand: return "hand.point.left.fill"
        }
    }
    var color: Color {
        switch self {
        case .control: return Theme.primary
        case .speed: return Color(hex: 0xFFC53D)
        case .coordination: return Theme.info
        case .reaction: return Color(hex: 0xFF5C8A)
        case .creativity: return Color(hex: 0xB06BFF)
        case .weakHand: return Theme.energy
        }
    }
}
