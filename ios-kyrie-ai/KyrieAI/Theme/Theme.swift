//
//  Theme.swift
//  KyrieAI
//
//  Central design system: colors, gradients, typography, spacing.
//

import SwiftUI

/// App-wide design tokens for a premium dark athletic aesthetic.
enum Theme {
    // MARK: - Core palette
    static let background = Color(hex: 0x0B0B0F)
    static let surface = Color(hex: 0x15151C)
    static let surfaceElevated = Color(hex: 0x1E1E28)
    static let stroke = Color.white.opacity(0.08)

    static let primary = Color(hex: 0xFF6B2C)      // basketball orange
    static let primaryDeep = Color(hex: 0xE34915)
    static let energy = Color(hex: 0xB8FF2E)        // electric lime
    static let info = Color(hex: 0x3DDCFF)          // cool cyan

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.38)

    // MARK: - Gradients
    static var fireGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0xFF8A3D), primary, primaryDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var energyGradient: LinearGradient {
        LinearGradient(
            colors: [energy, Color(hex: 0x6FE000)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var coolGradient: LinearGradient {
        LinearGradient(
            colors: [info, Color(hex: 0x2A8FFF)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var backgroundGradient: RadialGradient {
        RadialGradient(
            colors: [Color(hex: 0x1A1320), background],
            center: .top,
            startRadius: 5,
            endRadius: 700
        )
    }

    // MARK: - Radii / spacing
    static let radiusS: CGFloat = 12
    static let radiusM: CGFloat = 18
    static let radiusL: CGFloat = 26

    // MARK: - Typography
    /// Condensed athletic display font (headlines, scores, big numbers).
    static func display(_ size: CGFloat) -> Font {
        .custom("AvenirNextCondensed-Heavy", size: size)
    }

    /// Condensed athletic supporting font (subtitles, body emphasis).
    static func body(_ size: CGFloat) -> Font {
        .custom("AvenirNextCondensed-Medium", size: size)
    }
}

extension Color {
    /// Create a color from a 0xRRGGBB hex integer.
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

// MARK: - Reusable view modifiers

struct GlassCard: ViewModifier {
    var padding: CGFloat = 18
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.radiusL))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusL)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard(padding: CGFloat = 18) -> some View {
        modifier(GlassCard(padding: padding))
    }
}
