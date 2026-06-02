import Foundation
import Combine

@MainActor
final class RulesViewModel: ObservableObject {
    @Published var rules:       [Rule] = []
    @Published var showAddRule: Bool   = false

    private let ruleUseCases:        RuleUseCases
    private let notificationManager: NotificationManager

    init(
        ruleUseCases:        RuleUseCases        = DependencyContainer.shared.ruleUseCases,
        notificationManager: NotificationManager = .shared
    ) {
        self.ruleUseCases        = ruleUseCases
        self.notificationManager = notificationManager
    }

    func onAppear() { reload() }

    func reload() {
        rules = ruleUseCases.fetchAll()
    }

    func add(_ rule: Rule) {
        ruleUseCases.add(rule)
        scheduleIfNeeded(rule)
        reload()
    }

    func update(_ rule: Rule) {
        ruleUseCases.update(rule)
        notificationManager.cancelScheduledNotifications(for: rule)
        scheduleIfNeeded(rule)
        reload()
    }

    func delete(_ offsets: IndexSet) {
        let toDelete = offsets.map { rules[$0] }
        for rule in toDelete {
            ruleUseCases.delete(id: rule.id)
            notificationManager.cancelScheduledNotifications(for: rule)
        }
        reload()
    }

    func toggle(_ rule: Rule) {
        ruleUseCases.toggleEnabled(rule)
        // rule.isEnabled is the pre-toggle state; if it was enabled (now disabling), cancel.
        if rule.isEnabled {
            notificationManager.cancelScheduledNotifications(for: rule)
        }
        reload()
        // If the rule is now enabled after toggle, schedule it.
        if let updated = rules.first(where: { $0.id == rule.id }), updated.isEnabled {
            scheduleIfNeeded(updated)
        }
    }

    private func scheduleIfNeeded(_ rule: Rule) {
        guard rule.isEnabled, case .timeBased(let trigger) = rule.triggerType else { return }
        let templates = DependencyContainer.shared.templateUseCases.fetchAll()
        let template  = templates
            .filter { $0.assignedRuleIds.contains(rule.id) || $0.isGlobal }
            .randomElement()
        notificationManager.scheduleTimeBasedRule(rule, trigger: trigger, template: template)
    }
}
