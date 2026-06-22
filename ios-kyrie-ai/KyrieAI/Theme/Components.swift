//
//  Components.swift
//  KyrieAI
//
//  Shared UI building blocks: buttons, rings, pills, backgrounds.
//

import SwiftUI

// MARK: - Primary button

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var gradient: LinearGradient = Theme.fireGradient
    var enabled: Bool = true
    let action: () -> Void

    @State private var pressed: Bool = false

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 10) {
                if let icon { Image(systemName: icon).font(.headline.weight(.bold)) }
                Text(title).font(.headline.weight(.bold))
            }
            .foregroundStyle(Color(hex: 0x140A04))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(gradient, in: .rect(cornerRadius: Theme.radiusM))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Theme.primary.opacity(enabled ? 0.45 : 0), radius: 18, y: 8)
            .scaleEffect(pressed ? 0.97 : 1)
            .opacity(enabled ? 1 : 0.4)
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.12)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pressed = false } }
        )
    }
}

// MARK: - Secondary / ghost button

struct GhostButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.light()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).fontWeight(.semibold)
            }
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.surfaceElevated, in: .rect(cornerRadius: Theme.radiusM))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Score ring

struct ScoreRing: View {
    let progress: Double          // 0...1
    var size: CGFloat = 180
    var lineWidth: CGFloat = 16
    var gradient: AngularGradient = AngularGradient(
        colors: [Theme.primary, Theme.energy, Theme.info, Theme.primary],
        center: .center
    )
    var label: AnyView? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.primary.opacity(0.5), radius: 10)
            if let label { label }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Tag / pill

struct TagPill: View {
    let text: String
    var color: Color = Theme.energy
    var filled: Bool = false

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(filled ? Color(hex: 0x0B0B0F) : color)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(
                filled ? AnyShapeStyle(color) : AnyShapeStyle(color.opacity(0.14)),
                in: .capsule
            )
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primary)
            }
        }
    }
}

// MARK: - Animated background

struct ArenaBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            // glowing orbs
            Circle()
                .fill(Theme.primary.opacity(0.22))
                .frame(width: 360)
                .blur(radius: 120)
                .offset(x: animate ? -120 : -90, y: animate ? -260 : -300)
            Circle()
                .fill(Theme.energy.opacity(0.12))
                .frame(width: 320)
                .blur(radius: 130)
                .offset(x: animate ? 150 : 120, y: animate ? 320 : 360)
            Circle()
                .fill(Theme.info.opacity(0.08))
                .frame(width: 260)
                .blur(radius: 110)
                .offset(x: animate ? -140 : -160, y: animate ? 200 : 240)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Stat chip

struct StatChip: View {
    let value: String
    let label: String
    var tint: Color = Theme.primary
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
            }
            Text(value)
                .font(.title2.weight(.heavy))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusM))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .strokeBorder(Theme.stroke, lineWidth: 1)
        )
    }
}
