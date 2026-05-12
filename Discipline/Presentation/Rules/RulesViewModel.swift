import Foundation
import Combine

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
        if rule.isEnabled {
            notificationManager.cancelScheduledNotifications(for: rule)
        } else {
            // rule.isEnabled was true before toggle — now disabled, so cancel
            // (toggled state not yet reloaded; handled above).
        }
        reload()
        // Re-schedule if newly enabled.
        if let updated = rules.first(where: { $0.id == rule.id }), updated.isEnabled {
            scheduleIfNeeded(updated)
        }
    }

    private func scheduleIfNeeded(_ rule: Rule) {
        guard rule.isEnabled, case .timeBased(let trigger) = rule.triggerType else { return }
        notificationManager.scheduleTimeBasedRule(rule, trigger: trigger)
    }
}
