//
//  StreakWidgetSync.swift
//  KyrieAI
//
//  Bridges the SwiftData PlayerProfile into the shared streak channel and
//  asks WidgetKit to refresh the Home Screen streak widget.
//

import Foundation
import WidgetKit

enum StreakWidgetSync {
    /// Builds a snapshot from the profile, writes it to the App Group, and reloads the widget.
    static func sync(from profile: PlayerProfile, calendar: Calendar = .current) {
        let dayKeys = profile.sessions.map { StreakSnapshot.dayKey(for: $0.date, calendar: calendar) }
        // Keep this bounded — the widget only needs the recent window.
        let recent = Array(Set(dayKeys)).suffix(60)

        let snapshot = StreakSnapshot(
            currentStreak: profile.currentStreak,
            longestStreak: profile.longestStreak,
            totalXP: profile.totalXP,
            lastTrainedAt: profile.lastTrainedAt,
            trainedDayKeys: Array(recent)
        )
        StreakWidgetStore.save(snapshot)
        WidgetCenter.shared.reloadTimelines(ofKind: StreakWidgetStore.widgetKind)
    }
}
