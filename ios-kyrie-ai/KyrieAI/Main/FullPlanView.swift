//
//  FullPlanView.swift
//  KyrieAI
//
//  A full read-only breakdown of the player's personalized training plan.
//

import SwiftUI

struct FullPlanView: View {
    let profile: PlayerProfile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ArenaBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        scheduleSection
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Your Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    /// The training days the player committed to, sorted Mon→Sun.
    private var orderedTrainingDays: [Weekday] {
        profile.trainingDays.sorted { $0.order < $1.order }
    }

    /// The date of a given weekday within the current week.
    private func date(for day: Weekday) -> Date {
        let calendar = Calendar.current
        let weekdayNumber: Int = {
            switch day {
            case .sunday: return 1
            case .monday: return 2
            case .tuesday: return 3
            case .wednesday: return 4
            case .thursday: return 5
            case .friday: return 6
            case .saturday: return 7
            }
        }()
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        return calendar.date(
            byAdding: .day,
            value: 0,
            to: calendar.nextDate(
                after: calendar.date(byAdding: .second, value: -1, to: startOfWeek) ?? startOfWeek,
                matching: DateComponents(weekday: weekdayNumber),
                matchingPolicy: .nextTime
            ) ?? today
        ) ?? today
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("This Week", icon: "calendar", tint: Theme.info)
            Text("\(profile.trainingDays.count) days / week · \(profile.availability.subtitle)")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            if orderedTrainingDays.isEmpty {
                Text("No training days selected yet. Retake the quiz to set your schedule.")
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
            } else {
                VStack(spacing: 10) {
                    ForEach(orderedTrainingDays) { day in
                        let mode = TrainingModeCatalog.mode(for: date(for: day), weakest: profile.weakestCategories)
                        let isToday = Calendar.current.isDateInToday(date(for: day))
                        HStack(spacing: 12) {
                            VStack(spacing: 2) {
                                Text(day.short.uppercased())
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(isToday ? Color(hex: 0x0B0B0F) : Theme.textSecondary)
                            }
                            .frame(width: 42, height: 42)
                            .background(
                                isToday ? AnyShapeStyle(Theme.info) : AnyShapeStyle(Theme.surfaceElevated),
                                in: .rect(cornerRadius: 11)
                            )
                            Image(systemName: mode.icon)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(mode.tint)
                                .frame(width: 32, height: 32)
                                .background(mode.tint.opacity(0.15), in: .rect(cornerRadius: 9))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.title)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("\(mode.defaultReps) moves · ~8 min")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer(minLength: 0)
                            if isToday {
                                TagPill(text: "TODAY", color: Theme.info, filled: true)
                            }
                        }
                    }
                }
            }
        }
        .glassCard()
    }

    private func sectionTitle(_ title: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(tint)
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}
