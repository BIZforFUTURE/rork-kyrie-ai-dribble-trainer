//
//  PlayerProfile.swift
//  KyrieAI
//
//  Persistent player profile, training history, and progress.
//

import Foundation
import SwiftData

@Model
final class PlayerProfile {
    var name: String
    var age: Int
    var heightInches: Int          // total inches
    var skillLevelRaw: String
    var positionRaw: String
    var dominantHandRaw: String
    var goalRaws: [String]
    var trainingDayRaws: [String] = []
    var specificRequests: String = ""

    var hasOnboarded: Bool
    var hasSeenPaywall: Bool = false
    var hasAssessment: Bool

    var ballHandlerScore: Int
    // category scores 0...100
    var controlScore: Int
    var speedScore: Int
    var coordinationScore: Int
    var reactionScore: Int
    var creativityScore: Int
    var weakHandScore: Int

    var totalXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastTrainedAt: Date?
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var sessions: [SessionRecord]

    init(
        name: String = "",
        age: Int = 16,
        heightInches: Int = 70,
        skillLevel: SkillLevel = .beginner,
        position: Position = .pointGuard,
        dominantHand: Hand = .right,
        goals: [TrainingGoal] = [],
        trainingDays: [Weekday] = [],
        specificRequests: String = ""
    ) {
        self.name = name
        self.age = age
        self.heightInches = heightInches
        self.skillLevelRaw = skillLevel.rawValue
        self.positionRaw = position.rawValue
        self.dominantHandRaw = dominantHand.rawValue
        self.goalRaws = goals.map(\.rawValue)
        self.trainingDayRaws = trainingDays.map(\.rawValue)
        self.specificRequests = specificRequests
        self.hasOnboarded = false
        self.hasSeenPaywall = false
        self.hasAssessment = false
        self.ballHandlerScore = 0
        self.controlScore = 0
        self.speedScore = 0
        self.coordinationScore = 0
        self.reactionScore = 0
        self.creativityScore = 0
        self.weakHandScore = 0
        self.totalXP = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastTrainedAt = nil
        self.createdAt = Date()
        self.sessions = []
    }
}

// MARK: - Convenience accessors

extension PlayerProfile {
    var skillLevel: SkillLevel { SkillLevel(rawValue: skillLevelRaw) ?? .beginner }
    var position: Position { Position(rawValue: positionRaw) ?? .pointGuard }
    var dominantHand: Hand { Hand(rawValue: dominantHandRaw) ?? .right }
    var goals: [TrainingGoal] { goalRaws.compactMap { TrainingGoal(rawValue: $0) } }

    /// Selected training days, sorted Monday-first.
    var trainingDays: [Weekday] {
        trainingDayRaws.compactMap { Weekday(rawValue: $0) }.sorted { $0.order < $1.order }
    }

    /// Weekly commitment tier derived from the number of selected training days.
    var availability: Availability { Availability.from(dayCount: trainingDays.count) }

    var heightFormatted: String {
        let feet = heightInches / 12
        let inches = heightInches % 12
        return "\(feet)'\(inches)\""
    }

    var firstName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    func score(for category: SkillCategory) -> Int {
        switch category {
        case .control: return controlScore
        case .speed: return speedScore
        case .coordination: return coordinationScore
        case .reaction: return reactionScore
        case .creativity: return creativityScore
        case .weakHand: return weakHandScore
        }
    }

    func setScore(_ value: Int, for category: SkillCategory) {
        let v = max(0, min(100, value))
        switch category {
        case .control: controlScore = v
        case .speed: speedScore = v
        case .coordination: coordinationScore = v
        case .reaction: reactionScore = v
        case .creativity: creativityScore = v
        case .weakHand: weakHandScore = v
        }
    }

    /// The two lowest-scoring categories — what the plan targets.
    var weakestCategories: [SkillCategory] {
        SkillCategory.allCases
            .sorted { score(for: $0) < score(for: $1) }
            .prefix(2)
            .map { $0 }
    }

    var tier: String {
        switch ballHandlerScore {
        case ..<50: return "Rookie Handle"
        case 50..<65: return "Rising Handle"
        case 65..<78: return "Bucket Getter"
        case 78..<90: return "Elite Handle"
        default: return "Untouchable"
        }
    }
}
