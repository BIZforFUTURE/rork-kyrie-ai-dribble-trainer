//
//  SelectionComponents.swift
//  KyrieAI
//
//  Reusable selectable rows / cards used in onboarding.
//

import SwiftUI

struct SelectRow: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    let isSelected: Bool
    var tint: Color = Theme.primary
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.select()
            action()
        } label: {
            HStack(spacing: 14) {
                if let icon {
                    Image(systemName: icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(isSelected ? tint : Theme.textSecondary)
                        .frame(width: 30)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? tint : Theme.textTertiary, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle().fill(tint).frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                (isSelected ? tint.opacity(0.12) : Theme.surface),
                in: .rect(cornerRadius: Theme.radiusM)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(isSelected ? tint.opacity(0.6) : Theme.stroke, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SelectChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    var tint: Color = Theme.primary
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.select()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.subheadline.weight(.bold)) }
                Text(title).font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Color(hex: 0x0B0B0F) : Theme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ? AnyShapeStyle(tint) : AnyShapeStyle(Theme.surface),
                in: .capsule
            )
            .overlay(
                Capsule().strokeBorder(isSelected ? .clear : Theme.stroke, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
