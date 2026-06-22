//
//  LeaderboardView.swift
//  KyrieAI
//
//  Weekly ranks. The player is slotted in against simulated rivals based on
//  their XP, with a podium for the top three.
//

import SwiftUI

private struct Ranker: Identifiable {
    let id = UUID()
    let name: String
    let xp: Int
    let isPlayer: Bool
}

struct LeaderboardView: View {
    let profile: PlayerProfile
    @State private var scope: Int = 0   // 0 = friends, 1 = global

    private var rankers: [Ranker] {
        let bots = LeaderboardView.botNames(global: scope == 1)
        var list = bots.enumerated().map { idx, name in
            // deterministic-ish xp spread
            Ranker(name: name, xp: 2400 - idx * (scope == 1 ? 150 : 220) + (name.count * 13), isPlayer: false)
        }
        list.append(Ranker(name: profile.firstName.isEmpty ? "You" : profile.firstName, xp: max(120, profile.totalXP), isPlayer: true))
        return list.sorted { $0.xp > $1.xp }
    }

    var body: some View {
        ZStack {
            ArenaBackground()
            ScrollView {
                VStack(spacing: 20) {
                    header
                    scopePicker
                    podium
                    list
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RANKS").font(Theme.body(14).weight(.heavy)).tracking(2).foregroundStyle(Theme.primary)
            Text("This week's grind")
                .font(Theme.display(32))
                .foregroundStyle(Theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var scopePicker: some View {
        HStack(spacing: 8) {
            scopeButton("Crew", 0)
            scopeButton("Global", 1)
        }
    }

    private func scopeButton(_ title: String, _ tag: Int) -> some View {
        Button {
            withAnimation(.snappy) { scope = tag }
        } label: {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(scope == tag ? Color(hex: 0x0B0B0F) : Theme.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(scope == tag ? AnyShapeStyle(Theme.fireGradient) : AnyShapeStyle(Theme.surface), in: .capsule)
                .overlay(Capsule().strokeBorder(scope == tag ? .clear : Theme.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var podium: some View {
        let top = Array(rankers.prefix(3))
        return HStack(alignment: .bottom, spacing: 12) {
            if top.count > 1 { podiumColumn(top[1], place: 2, height: 90) }
            if !top.isEmpty { podiumColumn(top[0], place: 1, height: 120) }
            if top.count > 2 { podiumColumn(top[2], place: 3, height: 70) }
        }
        .frame(maxWidth: .infinity)
    }

    private func podiumColumn(_ r: Ranker, place: Int, height: CGFloat) -> some View {
        let tint: Color = place == 1 ? Color(hex: 0xFFC53D) : (place == 2 ? Color(hex: 0xC8D2DA) : Color(hex: 0xCD7F32))
        return VStack(spacing: 8) {
            ZStack {
                Circle().fill(tint.opacity(0.2)).frame(width: 56, height: 56)
                Text(initials(r.name)).font(.headline.weight(.heavy)).foregroundStyle(tint)
                if place == 1 {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundStyle(tint)
                        .offset(y: -38)
                }
            }
            Text(r.name).font(.caption.weight(.bold)).foregroundStyle(Theme.textPrimary).lineLimit(1)
            Text("\(r.xp)").font(.caption2.weight(.semibold)).foregroundStyle(Theme.textSecondary)
            RoundedRectangle(cornerRadius: 10)
                .fill(r.isPlayer ? AnyShapeStyle(Theme.fireGradient) : AnyShapeStyle(tint.opacity(0.3)))
                .frame(height: height)
                .overlay(Text("\(place)").font(.title.weight(.black)).foregroundStyle(.white.opacity(0.9)))
        }
        .frame(maxWidth: .infinity)
    }

    private var list: some View {
        VStack(spacing: 10) {
            ForEach(Array(rankers.enumerated()), id: \.element.id) { idx, r in
                HStack(spacing: 14) {
                    Text("\(idx + 1)")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 26)
                    ZStack {
                        Circle().fill(r.isPlayer ? Theme.primary.opacity(0.25) : Theme.surfaceElevated).frame(width: 38, height: 38)
                        Text(initials(r.name)).font(.caption.weight(.heavy)).foregroundStyle(r.isPlayer ? Theme.primary : Theme.textSecondary)
                    }
                    Text(r.name)
                        .font(.subheadline.weight(r.isPlayer ? .heavy : .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("\(r.xp) XP")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(r.isPlayer ? Theme.primary : Theme.textSecondary)
                }
                .padding(.vertical, 12).padding(.horizontal, 14)
                .background(r.isPlayer ? Theme.primary.opacity(0.10) : Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
                .overlay(RoundedRectangle(cornerRadius: Theme.radiusM).strokeBorder(r.isPlayer ? Theme.primary.opacity(0.5) : Theme.stroke, lineWidth: 1))
            }
        }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if let first = parts.first?.first {
            if parts.count > 1, let second = parts[1].first { return "\(first)\(second)" }
            return String(first)
        }
        return "?"
    }

    static func botNames(global: Bool) -> [String] {
        global
            ? ["Marcus T.", "Deja W.", "Kenji R.", "Sofia L.", "Andre P.", "Mateo G.", "Nia C.", "Liam B."]
            : ["Jordan", "Tyrese", "Maya", "Devin", "Coach Rob", "Zion", "Ella"]
    }
}
