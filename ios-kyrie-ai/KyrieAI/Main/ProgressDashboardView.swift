//
//  ProgressDashboardView.swift
//  KyrieAI
//
//  Tracks the player's growth: score, skill radar, streaks, and history.
//

import SwiftUI

struct ProgressDashboardView: View {
    @Bindable var profile: PlayerProfile

    private var sortedSessions: [SessionRecord] {
        profile.sessions.sorted { $0.date > $1.date }
    }

    private var categoryScores: [SkillCategory: Int] {
        var d: [SkillCategory: Int] = [:]
        for cat in SkillCategory.allCases { d[cat] = profile.score(for: cat) }
        return d
    }

    var body: some View {
        ZStack {
            ArenaBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SectionHeader(title: "Skill Profile")
                    SkillRadar(scores: categoryScores)
                        .frame(height: 280)
                        .glassCard()
                    SectionHeader(title: "Skill Breakdown")
                    VStack(spacing: 10) {
                        ForEach(SkillCategory.allCases) { cat in
                            CategoryBar(category: cat, value: profile.score(for: cat), reveal: true)
                        }
                    }
                    .glassCard()
                    SectionHeader(title: "Recent Sessions")
                    if sortedSessions.isEmpty {
                        emptyHistory
                    } else {
                        VStack(spacing: 12) {
                            ForEach(sortedSessions.prefix(8)) { session in
                                SessionRow(session: session)
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var emptyHistory: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.basketball").font(.largeTitle).foregroundStyle(Theme.textTertiary)
            Text("No sessions yet").font(.headline).foregroundStyle(Theme.textPrimary)
            Text("Complete a training session to start tracking your growth.")
                .font(.caption).foregroundStyle(Theme.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

struct SessionRow: View {
    let session: SessionRecord

    private var mode: TrainingMode? { TrainingModeCatalog.mode(id: session.modeID) }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: mode?.icon ?? "figure.basketball")
                .font(.headline.weight(.bold))
                .foregroundStyle(mode?.tint ?? Theme.primary)
                .frame(width: 46, height: 46)
                .background((mode?.tint ?? Theme.primary).opacity(0.15), in: .rect(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(session.modeTitle).font(.subheadline.weight(.bold)).foregroundStyle(Theme.textPrimary)
                Text(session.date, format: .dateTime.weekday().month().day().hour().minute())
                    .font(.caption2).foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(session.accuracy)%").font(.subheadline.weight(.heavy)).foregroundStyle(mode?.tint ?? Theme.primary)
                Text("+\(session.xpEarned) XP").font(.caption2.weight(.semibold)).foregroundStyle(Theme.energy)
            }
        }
        .glassCard(padding: 14)
    }
}
