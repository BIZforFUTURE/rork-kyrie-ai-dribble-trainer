//
//  NotificationManager.swift
//  KyrieAI
//
//  Schedules daily training reminder notifications.
//

import Foundation
import UserNotifications

/// Handles permission and scheduling of the three daily training reminders,
/// plus the hidden win-back discount offer.
enum NotificationManager {
    /// Identifier for the win-back "50% off" notification.
    static let discountOfferID = "kyrie.winback.discount"
    /// userInfo key/value used to route a notification tap to the secret paywall.
    static let destinationKey = "destination"
    static let secretDiscountDestination = "secretDiscount"

    /// Schedules a one-shot win-back notification 5 minutes from now offering the
    /// hidden half-off first year. Only fires if the user has *already* granted
    /// notification permission; otherwise it silently does nothing (we never
    /// prompt here). Tapping it opens the secret discount paywall.
    static func scheduleDiscountOffer() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional else { return }

            let content = UNMutableNotificationContent()
            content.title = "🎁 A Gift for You"
            content.body = "Get 50% off your first year. Offer expires in 24 hrs."
            content.sound = .default
            content.userInfo = [destinationKey: secretDiscountDestination]

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 * 60, repeats: false)
            let request = UNNotificationRequest(
                identifier: discountOfferID,
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    /// Cancels a pending win-back offer (e.g. user returned to the app or upgraded).
    static func cancelDiscountOffer() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [discountOfferID])
    }

    /// A single daily reminder fired at a fixed hour.
    private struct DailyReminder {
        let hour: Int
        let minute: Int
        let title: String
        let body: String
    }

    private static let reminders: [DailyReminder] = [
        DailyReminder(
            hour: 8, minute: 30,
            title: "Morning reps 🏀",
            body: "Start your day with a quick handle warm-up. Coach has today's plan ready."
        ),
        DailyReminder(
            hour: 13, minute: 0,
            title: "Midday check-in",
            body: "Got 10 minutes? Knock out a few combos and keep your streak alive."
        ),
        DailyReminder(
            hour: 19, minute: 30,
            title: "Finish strong 🔥",
            body: "Don't let the day end without training. Get your session in now."
        ),
    ]

    /// Requests permission, then schedules the three repeating daily reminders.
    static func requestAndSchedule() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            schedule()
        }
    }

    /// Schedules (or re-schedules) the three daily reminders.
    static func schedule() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for (index, reminder) in reminders.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default

            var components = DateComponents()
            components.hour = reminder.hour
            components.minute = reminder.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "kyrie.daily.reminder.\(index)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }
}
