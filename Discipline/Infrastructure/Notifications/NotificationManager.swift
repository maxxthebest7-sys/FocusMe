import UserNotifications
import Foundation

final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerActionCategories()
    }

    // MARK: - Authorization

    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .timeSensitive]
        ) { granted, _ in
            DispatchQueue.main.async { completion?(granted) }
        }
    }

    // MARK: - Immediate delivery (conflict-based / background evaluation)

    func scheduleImmediateNotification(for rule: Rule, template: NotificationTemplate?) {
        guard let template else { return }

        let content = makeContent(from: template, ruleId: rule.id)
        // 1-second delay so iOS treats it as a real incoming notification.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id      = "rule-immediate-\(rule.id.uuidString)-\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    // MARK: - Calendar-based scheduling (time-based rules)

    func scheduleTimeBasedRule(_ rule: Rule, trigger: TimeBasedTrigger) {
        cancelScheduledNotifications(for: rule)

        // Use a generic title; the message library picks content per-fire via RuleEngine.
        // For pre-scheduled notifications we embed a sentinel so the delegate can look up
        // a real template at delivery time. For simplicity, we encode rule metadata.
        var comps        = DateComponents()
        comps.hour       = trigger.hour
        comps.minute     = trigger.minute

        let content                    = UNMutableNotificationContent()
        content.title                  = rule.name
        content.body                   = "Your rule fired. Open Discipline to review."
        content.sound                  = .defaultCritical
        content.categoryIdentifier     = NotificationCategory.ruleViolation.rawValue
        content.interruptionLevel      = .timeSensitive
        content.userInfo               = ["ruleId": rule.id.uuidString, "scheduled": true]

        let calTrigger = UNCalendarNotificationTrigger(
            dateMatching: comps,
            repeats: trigger.repeats
        )
        let request = UNNotificationRequest(
            identifier: scheduledId(for: rule),
            content: content,
            trigger: calTrigger
        )
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    func cancelScheduledNotifications(for rule: Rule) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [scheduledId(for: rule)])
    }

    // MARK: - Snooze

    func scheduleSnoozedNotification(for rule: Rule, template: NotificationTemplate?, minutes: Int = 5) {
        guard let template else { return }
        let content  = makeContent(from: template, ruleId: rule.id)
        let trigger  = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
            repeats: false
        )
        let id       = "rule-snoozed-\(rule.id.uuidString)"
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
        let request  = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    // MARK: - Private helpers

    private func makeContent(
        from template: NotificationTemplate,
        ruleId: UUID
    ) -> UNMutableNotificationContent {
        let content                = UNMutableNotificationContent()
        content.title              = template.title
        content.body               = template.body
        if !template.subtitle.isEmpty { content.subtitle = template.subtitle }
        content.sound              = .defaultCritical
        content.categoryIdentifier = NotificationCategory.ruleViolation.rawValue
        content.interruptionLevel  = .timeSensitive
        content.userInfo           = ["ruleId": ruleId.uuidString]
        return content
    }

    private func scheduledId(for rule: Rule) -> String {
        "rule-scheduled-\(rule.id.uuidString)"
    }

    private func registerActionCategories() {
        let stopAction = UNNotificationAction(
            identifier: NotificationAction.stop.rawValue,
            title: "I\'ll stop now",
            options: .foreground
        )
        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze.rawValue,
            title: "Give me 5 more minutes",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: NotificationCategory.ruleViolation.rawValue,
            actions: [stopAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

// MARK: - Delegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner + sound even when app is in foreground.
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo    = response.notification.request.content.userInfo
        let ruleIdStr   = userInfo["ruleId"] as? String ?? ""

        switch response.actionIdentifier {
        case NotificationAction.stop.rawValue:
            break   // User acknowledged — no further action needed.

        case NotificationAction.snooze.rawValue:
            NotificationCenter.default.post(
                name: .disciplineSnoozeRequested,
                object: nil,
                userInfo: ["ruleId": ruleIdStr]
            )

        default:
            break
        }
        completionHandler()
    }
}

// MARK: - Enums

enum NotificationCategory: String {
    case ruleViolation = "RULE_VIOLATION"
}

enum NotificationAction: String {
    case stop   = "STOP_NOW"
    case snooze = "SNOOZE_5MIN"
}

extension Notification.Name {
    static let disciplineSnoozeRequested = Notification.Name("disciplineSnoozeRequested")
}
