//
//  StreakWidgetShared.swift
//  KyrieAIWidget
//
//  Shared streak data channel between the app and the Home Screen widget.
//  This file is mirrored from the KyrieAI app target.
//

import Foundation

/// Immutable snapshot of the player's streak state shared with the widget.
nonisolated struct StreakSnapshot: Equatable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalXP: Int = 0
    var lastTrainedAt: Date? = nil
    /// Day keys ("y-M-d") for every day the player has trained.
    var trainedDayKeys: [String] = []

    /// Stable day key independent of locale/timezone formatting quirks.
    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    /// True when a session was logged today.
    func trainedToday(asOf date: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard let last = lastTrainedAt else { return false }
        return calendar.isDateInToday(last) || calendar.isDate(last, inSameDayAs: date)
    }

    /// True when the streak is alive but today hasn't been trained yet (trained yesterday).
    func atRisk(asOf date: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard let last = lastTrainedAt, currentStreak > 0 else { return false }
        return calendar.isDateInYesterday(last)
    }

    /// True when more than a day has passed without training (streak broken).
    func isBroken(asOf date: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard let last = lastTrainedAt else { return true }
        if calendar.isDateInToday(last) || calendar.isDateInYesterday(last) { return false }
        return true
    }

    /// The streak to show — collapses to 0 once a day has been fully missed.
    func effectiveStreak(asOf date: Date = Date(), calendar: Calendar = .current) -> Int {
        isBroken(asOf: date, calendar: calendar) ? 0 : currentStreak
    }

    /// Short status line shown under the streak number.
    func statusLine(asOf date: Date = Date(), calendar: Calendar = .current) -> String {
        if trainedToday(asOf: date, calendar: calendar) { return "On fire" }
        if atRisk(asOf: date, calendar: calendar) { return "Don't break it" }
        if effectiveStreak(asOf: date, calendar: calendar) == 0 && lastTrainedAt == nil {
            return "Start today"
        }
        return "Train today"
    }

    /// The last 7 days (oldest → today) flagged as trained or not.
    func weekTrained(asOf date: Date = Date(), calendar: Calendar = .current) -> [Bool] {
        let keys = Set(trainedDayKeys)
        return (0..<7).reversed().map { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: date) else { return false }
            return keys.contains(StreakSnapshot.dayKey(for: day, calendar: calendar))
        }
    }
}

/// Reads and writes the streak snapshot through the shared App Group container.
nonisolated enum StreakWidgetStore {
    static let appGroup = "group.app.rork.isjxf9gj1lwsmsjtmbjze"
    static let widgetKind = "KyrieAIWidget"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroup)
    }

    static func save(_ snapshot: StreakSnapshot) {
        guard let d = defaults else { return }
        d.set(snapshot.currentStreak, forKey: "currentStreak")
        d.set(snapshot.longestStreak, forKey: "longestStreak")
        d.set(snapshot.totalXP, forKey: "totalXP")
        if let last = snapshot.lastTrainedAt {
            d.set(last.timeIntervalSince1970, forKey: "lastTrainedAt")
        } else {
            d.removeObject(forKey: "lastTrainedAt")
        }
        d.set(snapshot.trainedDayKeys, forKey: "trainedDayKeys")
    }

    static func load() -> StreakSnapshot {
        guard let d = defaults else { return StreakSnapshot() }
        let last = d.object(forKey: "lastTrainedAt") as? Double
        return StreakSnapshot(
            currentStreak: d.integer(forKey: "currentStreak"),
            longestStreak: d.integer(forKey: "longestStreak"),
            totalXP: d.integer(forKey: "totalXP"),
            lastTrainedAt: last.map { Date(timeIntervalSince1970: $0) },
            trainedDayKeys: d.stringArray(forKey: "trainedDayKeys") ?? []
        )
    }
}
