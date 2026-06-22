//
//  Haptics.swift
//  KyrieAI
//
//  Centralized haptic feedback. Generators are kept warm via `prepare()`
//  so taps feel instant. All calls are main-actor safe.
//

import UIKit

/// App-wide haptic feedback helper.
///
/// Use the semantic methods (`tap`, `select`, `success`, etc.) rather than
/// instantiating `UIFeedbackGenerator` directly so feedback stays consistent.
@MainActor
enum Haptics {
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private static let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private static let notification = UINotificationFeedbackGenerator()
    private static let selection = UISelectionFeedbackGenerator()

    // MARK: - Selection / navigation

    /// Light tick for picking an option (chips, rows, segmented choices).
    static func select() {
        selection.selectionChanged()
        selection.prepare()
    }

    /// Standard button / card tap.
    static func tap() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    /// Subtle tap for secondary / navigation controls (back, dismiss).
    static func light() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    /// Soft press for toggles and gentle UI changes.
    static func soft() {
        impactSoft.impactOccurred()
        impactSoft.prepare()
    }

    // MARK: - Training / drill beats

    /// Sharp beat used for move callouts and rep markers.
    static func beat() {
        impactRigid.impactOccurred()
        impactRigid.prepare()
    }

    /// Strong thump for big moments (session start, level up).
    static func heavy() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    // MARK: - Outcomes

    static func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    static func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    static func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }

    /// Warm up the generators so the first haptic fires without latency.
    static func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactRigid.prepare()
        impactSoft.prepare()
        notification.prepare()
        selection.prepare()
    }
}
