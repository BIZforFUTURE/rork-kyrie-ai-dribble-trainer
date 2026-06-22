import WidgetKit
import SwiftUI

// MARK: - Timeline

nonisolated struct StreakEntry: TimelineEntry {
    let date: Date
    let snapshot: StreakSnapshot
}

nonisolated struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, snapshot: StreakSnapshot(currentStreak: 7, longestStreak: 12, totalXP: 2450, lastTrainedAt: .now, trainedDayKeys: []))
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: .now, snapshot: StreakWidgetStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let snapshot = StreakWidgetStore.load()
        let now = Date()
        let entry = StreakEntry(date: now, snapshot: snapshot)

        // Refresh at the start of tomorrow so a missed day flips to "at risk"/reset.
        let cal = Calendar.current
        let nextMidnight = cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTime) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

// MARK: - Palette

private enum WidgetPalette {
    static let background = Color(red: 0.043, green: 0.043, blue: 0.059)
    static let glowTop = Color(red: 0.102, green: 0.075, blue: 0.125)
    static let orangeLight = Color(red: 1.0, green: 0.541, blue: 0.239)
    static let orange = Color(red: 1.0, green: 0.420, blue: 0.173)
    static let orangeDeep = Color(red: 0.890, green: 0.286, blue: 0.082)
    static let energy = Color(red: 0.722, green: 1.0, blue: 0.180)
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.34)

    static var fire: LinearGradient {
        LinearGradient(colors: [orangeLight, orange, orangeDeep], startPoint: .top, endPoint: .bottom)
    }
    static var cooled: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0.3)], startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Background

private struct WidgetBackground: View {
    var body: some View {
        ZStack {
            WidgetPalette.background
            RadialGradient(
                colors: [WidgetPalette.glowTop, WidgetPalette.background],
                center: .top,
                startRadius: 4,
                endRadius: 260
            )
        }
    }
}

// MARK: - Flame badge

private struct FlameBadge: View {
    let hot: Bool
    var size: CGFloat = 54

    var body: some View {
        ZStack {
            Circle()
                .fill(hot ? WidgetPalette.orange.opacity(0.22) : Color.white.opacity(0.06))
                .frame(width: size, height: size)
            Image(systemName: "flame.fill")
                .font(.system(size: size * 0.5, weight: .black))
                .foregroundStyle(hot ? AnyShapeStyle(WidgetPalette.fire) : AnyShapeStyle(WidgetPalette.cooled))
                .shadow(color: hot ? WidgetPalette.orange.opacity(0.7) : .clear, radius: 8)
        }
    }
}

// MARK: - Small

private struct SmallStreakView: View {
    let snapshot: StreakSnapshot
    var streak: Int { snapshot.effectiveStreak() }
    var hot: Bool { streak > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                FlameBadge(hot: hot, size: 46)
                Spacer()
                Text("STREAK")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(WidgetPalette.textTertiary)
            }
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(streak)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(hot ? AnyShapeStyle(WidgetPalette.fire) : AnyShapeStyle(Color.white.opacity(0.5)))
                Text(streak == 1 ? "day" : "days")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetPalette.textSecondary)
            }
            Text(snapshot.statusLine())
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(hot ? WidgetPalette.orangeLight : WidgetPalette.textSecondary)
        }
    }
}

// MARK: - Medium

private struct MediumStreakView: View {
    let snapshot: StreakSnapshot
    var streak: Int { snapshot.effectiveStreak() }
    var hot: Bool { streak > 0 }

    private let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        HStack(spacing: 16) {
            // Left: flame + streak
            VStack(alignment: .leading, spacing: 6) {
                FlameBadge(hot: hot, size: 50)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundStyle(hot ? AnyShapeStyle(WidgetPalette.fire) : AnyShapeStyle(Color.white.opacity(0.5)))
                    Text(streak == 1 ? "day" : "days")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetPalette.textSecondary)
                }
                Text(snapshot.statusLine())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(hot ? WidgetPalette.orangeLight : WidgetPalette.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: stats + week row
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    statBlock(value: "\(snapshot.longestStreak)", label: "BEST", tint: WidgetPalette.orangeLight)
                    statBlock(value: xpLabel, label: "XP", tint: WidgetPalette.energy)
                }
                weekRow
            }
        }
    }

    private var xpLabel: String {
        let xp = snapshot.totalXP
        if xp >= 1000 {
            let k = Double(xp) / 1000
            return String(format: "%.1fk", k)
        }
        return "\(xp)"
    }

    private func statBlock(value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(tint)
            Text(label)
                .font(.system(size: 9, weight: .heavy))
                .tracking(1)
                .foregroundStyle(WidgetPalette.textTertiary)
        }
    }

    private var weekRow: some View {
        let week = snapshot.weekTrained()
        return HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { i in
                VStack(spacing: 4) {
                    Circle()
                        .fill(week[i] ? AnyShapeStyle(WidgetPalette.fire) : AnyShapeStyle(Color.white.opacity(0.08)))
                        .frame(width: 13, height: 13)
                        .overlay {
                            if week[i] {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundStyle(.white)
                            }
                        }
                    Text(dayLetters[i])
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(WidgetPalette.textTertiary)
                }
            }
        }
    }
}

// MARK: - Container

struct KyrieStreakWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                MediumStreakView(snapshot: entry.snapshot)
            default:
                SmallStreakView(snapshot: entry.snapshot)
            }
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}

struct KyrieAIWidget: Widget {
    let kind: String = "KyrieAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            KyrieStreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Training Streak")
        .description("Keep your Kyrie AI streak burning right on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
