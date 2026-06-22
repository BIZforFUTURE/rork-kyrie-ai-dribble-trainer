//
//  OnboardingDraft.swift
//  KyrieAI
//
//  Mutable state collected across the onboarding steps.
//

import SwiftUI

@Observable
final class OnboardingDraft {
    var name: String = ""
    var age: Int = 16
    var heightInches: Int = 70
    var skillLevel: SkillLevel? = nil
    var position: Position? = nil
    var dominantHand: Hand? = nil
    var goals: Set<TrainingGoal> = []
    var trainingDays: Set<Weekday> = []
    var specificRequests: String = ""

    func canContinue(from step: OnboardingStep) -> Bool {
        switch step {
        case .welcome: return true
        case .drill: return true
        case .progress: return true
        case .stat: return true
        case .impact: return true
        case .turnovers: return true
        case .rate: return true
        case .quizIntro: return true
        case .name: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .physicals: return true
        case .skill: return skillLevel != nil
        case .position: return position != nil
        case .hand: return dominantHand != nil
        case .goals: return !goals.isEmpty
        case .availability: return !trainingDays.isEmpty
        case .requests: return true
        case .ready: return true
        }
    }
}

enum OnboardingStep: Int, CaseIterable {
    case welcome, drill, progress, stat, impact, turnovers, rate, quizIntro, name, physicals, skill, position, hand, goals, availability, requests, ready

    var progressIndex: Int { rawValue }
}
