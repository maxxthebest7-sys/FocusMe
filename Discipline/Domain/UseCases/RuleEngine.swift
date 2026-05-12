import Foundation

/// Evaluates all enabled rules against the current time and schedule,
/// firing notifications for any that match and have passed their cooldown.
final class RuleEngine {
    private let ruleRepository: RuleRepository
    private let scheduleRepository: ScheduleRepository
    private let templateRepository: TemplateRepository
    private let notificationManager: NotificationManager
    private let cooldownManager: CooldownManager

    init(
        ruleRepository: RuleRepository,
        scheduleRepository: ScheduleRepository,
        templateRepository: TemplateRepository,
        notificationManager: NotificationManager,
        cooldownManager: CooldownManager = .shared
    ) {
        self.ruleRepository       = ruleRepository
        self.scheduleRepository   = scheduleRepository
        self.templateRepository   = templateRepository
        self.notificationManager  = notificationManager
        self.cooldownManager      = cooldownManager
    }

    func evaluateAllRules() {
        let cal     = Calendar.current
        let now     = Date()
        let hour    = cal.component(.hour,    from: now)
        let minute  = cal.component(.minute,  from: now)
        let weekday = cal.component(.weekday, from: now)

        guard let currentDay = DayOfWeek(rawValue: weekday) else { return }

        let schedule  = scheduleRepository.fetch()
        let rules     = ruleRepository.fetchAll()
        let templates = templateRepository.fetchAll()

        for rule in rules where rule.isEnabled && rule.activeDays.contains(currentDay) {
            guard shouldFire(rule: rule, hour: hour, minute: minute, schedule: schedule) else { continue }
            guard cooldownManager.canFire(rule: rule) else { continue }

            let template = selectTemplate(for: rule, from: templates)
            notificationManager.scheduleImmediateNotification(for: rule, template: template)
            cooldownManager.recordFired(rule: rule)
        }
    }

    private func shouldFire(rule: Rule, hour: Int, minute: Int, schedule: Schedule) -> Bool {
        switch rule.triggerType {
        case .timeBased(let t):
            return t.hour == hour && t.minute == minute

        case .conflictBased(let t):
            return schedule.blocks
                .filter { $0.type == t.conflictingScheduleBlockType }
                .contains { $0.isActive(hour: hour, minute: minute) }

        // App-based triggers require the FamilyControls entitlement and are
        // handled by ScreenTimeManager, not polled here.
        case .appBased, .durationBased:
            return false
        }
    }

    private func selectTemplate(
        for rule: Rule,
        from templates: [NotificationTemplate]
    ) -> NotificationTemplate? {
        let ruleTemplates = templates.filter { $0.assignedRuleIds.contains(rule.id) }
        if !ruleTemplates.isEmpty { return ruleTemplates.randomElement() }
        let global = templates.filter { $0.isGlobal }
        return global.randomElement()
    }
}
