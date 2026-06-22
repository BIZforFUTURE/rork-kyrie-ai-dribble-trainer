//
//  OnboardingView.swift
//  KyrieAI
//
//  Cinematic multi-step onboarding that builds the player's profile.
//

import SwiftUI
import SwiftData
import StoreKit

struct OnboardingView: View {
    /// When set, onboarding updates this existing profile instead of inserting a
    /// new one — used when restarting onboarding via the `kyrieai://start` deep link.
    var existingProfile: PlayerProfile? = nil
    /// Called after the profile is committed (e.g. to dismiss a presenting cover).
    var onComplete: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @State private var draft = OnboardingDraft()
    @State private var step: OnboardingStep = .welcome
    /// Drives the in-slide reveal phases on the stat sell slide (0 = hook, 1 = stat, 2 = promise).
    @State private var statPhase: Int = 0

    var body: some View {
        ZStack {
            ArenaBackground()

            VStack(spacing: 0) {
                if step != .welcome {
                    progressBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                Group {
                    switch step {
                    case .welcome: WelcomeStep()
                    case .drill: DrillStep()
                    case .progress: ProgressStep()
                    case .stat: StatStep(phase: statPhase)
                    case .impact: ImpactStep()
                    case .turnovers: TurnoversStep()
                    case .rate: RateStep()
                    case .quizIntro: QuizIntroStep()
                    case .name: NameStep(draft: draft)
                    case .physicals: PhysicalsStep(draft: draft)
                    case .skill: SkillStep(draft: draft)
                    case .position: PositionStep(draft: draft)
                    case .hand: HandStep(draft: draft)
                    case .goals: GoalsStep(draft: draft)
                    case .availability: AvailabilityStep(draft: draft)
                    case .requests: RequestsStep(draft: draft)
                    case .ready: ReadyStep(draft: draft)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .frame(maxHeight: .infinity)

                footer
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var progressBar: some View {
        let total = Double(OnboardingStep.allCases.count - 1)
        let value = Double(step.progressIndex) / total
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(Theme.fireGradient)
                    .frame(width: max(8, geo.size.width * value))
            }
        }
        .frame(height: 6)
    }

    private var footer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                if step != .welcome {
                    Button {
                        Haptics.light()
                        goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                            .frame(width: 56, height: 56)
                            .background(Theme.surfaceElevated, in: .circle)
                            .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                PrimaryButton(
                    title: primaryTitle,
                    icon: primaryIcon,
                    enabled: draft.canContinue(from: step)
                ) {
                    advance()
                }
            }

            if step == .rate {
                Button {
                    Haptics.light()
                    goNext()
                } label: {
                    Text("Maybe later")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var primaryTitle: String {
        switch step {
        case .welcome: return "Let's Go"
        case .rate: return "Rate & Continue"
        case .ready: return "Start Assessment"
        default: return "Continue"
        }
    }

    private var primaryIcon: String? {
        switch step {
        case .rate: return "star.fill"
        case .ready: return "scope"
        default: return nil
        }
    }

    private func advance() {
        if step == .ready {
            commitProfile()
            return
        }
        if step == .stat, statPhase < 2 {
            Haptics.light()
            withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) { statPhase += 1 }
            return
        }
        if step == .rate {
            requestReview()
        }
        goNext()
    }

    private func goNext() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            step = OnboardingStep(rawValue: step.rawValue + 1) ?? .ready
        }
        if step == .stat { statPhase = 0 }
    }

    private func goBack() {
        if step == .stat, statPhase > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { statPhase -= 1 }
            return
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            step = OnboardingStep(rawValue: step.rawValue - 1) ?? .welcome
        }
        if step == .stat { statPhase = 2 }
    }

    private func commitProfile() {
        Haptics.success()
        let name = draft.name.trimmingCharacters(in: .whitespaces)
        let requests = draft.specificRequests.trimmingCharacters(in: .whitespacesAndNewlines)
        if let profile = existingProfile {
            // Returning user re-running onboarding from a deep link: update in place.
            profile.name = name
            profile.age = draft.age
            profile.heightInches = draft.heightInches
            profile.skillLevelRaw = (draft.skillLevel ?? .beginner).rawValue
            profile.positionRaw = (draft.position ?? .pointGuard).rawValue
            profile.dominantHandRaw = (draft.dominantHand ?? .right).rawValue
            profile.goalRaws = Array(draft.goals).map(\.rawValue)
            profile.trainingDayRaws = Array(draft.trainingDays).map(\.rawValue)
            profile.specificRequests = requests
            profile.hasOnboarded = true
        } else {
            let profile = PlayerProfile(
                name: name,
                age: draft.age,
                heightInches: draft.heightInches,
                skillLevel: draft.skillLevel ?? .beginner,
                position: draft.position ?? .pointGuard,
                dominantHand: draft.dominantHand ?? .right,
                goals: Array(draft.goals),
                trainingDays: Array(draft.trainingDays),
                specificRequests: requests
            )
            profile.hasOnboarded = true
            modelContext.insert(profile)
        }
        try? modelContext.save()
        NotificationManager.requestAndSchedule()
        onComplete?()
    }
}

// MARK: - Step scaffold

struct StepScaffold<Content: View>: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(eyebrow.uppercased())
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Theme.primary)
                        .tracking(2)
                    Text(title)
                        .font(.custom("AvenirNextCondensed-Heavy", size: 38))
                        .tracking(1)
                        .foregroundStyle(Theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.custom("AvenirNextCondensed-Medium", size: 18))
                            .tracking(0.5)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                content
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }
}
