//
//  AssessmentResultView.swift
//  KyrieAI
//
//  Dramatic reveal of the Ball Handler Score, category radar, and the
//  AI-generated development focus.
//

import SwiftUI

struct AssessmentResultView: View {
    let profile: PlayerProfile
    let categories: [SkillCategory: Int]
    let score: Int
    let onContinue: () -> Void

    @State private var animatedScore: Int = 0
    @State private var ringProgress: Double = 0
    @State private var revealRadar = false

    private var weakest: [SkillCategory] {
        SkillCategory.allCases.sorted { (categories[$0] ?? 0) < (categories[$1] ?? 0) }.prefix(2).map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {
                VStack(spacing: 6) {
                    Text("YOUR BALL HANDLER SCORE")
                        .font(.caption.weight(.heavy)).tracking(2)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 30)

                ScoreRing(progress: ringProgress, size: 240, lineWidth: 20, label: AnyView(
                    VStack(spacing: 2) {
                        Text("\(animatedScore)")
                            .font(.system(size: 76, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .contentTransition(.numericText())
                        Text(tier)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.primary)
                    }
                ))

                SkillRadar(scores: categories)
                    .frame(height: 260)
                    .padding(.horizontal, 20)
                    .opacity(revealRadar ? 1 : 0)
                    .scaleEffect(revealRadar ? 1 : 0.85)

                // category breakdown
                VStack(spacing: 10) {
                    ForEach(SkillCategory.allCases) { cat in
                        CategoryBar(category: cat, value: categories[cat] ?? 0, reveal: revealRadar)
                    }
                }
                .padding(.horizontal, 20)

                // plan focus
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars").foregroundStyle(Theme.energy)
                        Text("Your Custom Development Plan")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    Text("Coach built a plan around your weakest areas and goals:")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    ForEach(weakest) { cat in
                        HStack(spacing: 12) {
                            Image(systemName: cat.icon)
                                .foregroundStyle(cat.color)
                                .frame(width: 26)
                            Text("Prioritize \(cat.rawValue)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            TagPill(text: "FOCUS", color: cat.color, filled: true)
                        }
                    }
                    let request = profile.specificRequests.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !request.isEmpty {
                        Divider().overlay(Theme.stroke)
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "quote.opening")
                                .foregroundStyle(Theme.energy)
                                .frame(width: 26)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your request")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Theme.textSecondary)
                                Text(request)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
                .glassCard()
                .padding(.horizontal, 20)

                PrimaryButton(title: "Enter the Lab", icon: "arrow.right") {
                    onContinue()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .scrollIndicators(.hidden)
        .onAppear { runReveal() }
    }

    private var tier: String {
        switch score {
        case ..<50: return "Rookie Handle"
        case 50..<65: return "Rising Handle"
        case 65..<78: return "Bucket Getter"
        case 78..<90: return "Elite Handle"
        default: return "Untouchable"
        }
    }

    private func runReveal() {
        withAnimation(.easeOut(duration: 1.4)) { ringProgress = Double(score) / 100 }
        // count up
        let steps = max(1, score)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (1.4 / Double(steps))) {
                animatedScore = i
                if i == steps { Haptics.success() }
            }
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8)) { revealRadar = true }
    }
}

// MARK: - Category bar

struct CategoryBar: View {
    let category: SkillCategory
    let value: Int
    let reveal: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(category.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 104, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.07))
                    Capsule()
                        .fill(category.color)
                        .frame(width: reveal ? geo.size.width * CGFloat(value) / 100 : 0)
                }
            }
            .frame(height: 8)
            Text("\(value)")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}
