import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var rules:       [Rule]          = []
    @Published var schedule:    Schedule        = Schedule()
    @Published var activeBlock: ScheduleBlock?  = nil
    @Published var currentTime: String          = ""

    private let ruleUseCases:     RuleUseCases
    private let scheduleUseCases: ScheduleUseCases
    private var clockTimer:       Timer?

    init(
        ruleUseCases:     RuleUseCases     = DependencyContainer.shared.ruleUseCases,
        scheduleUseCases: ScheduleUseCases = DependencyContainer.shared.scheduleUseCases
    ) {
        self.ruleUseCases     = ruleUseCases
        self.scheduleUseCases = scheduleUseCases
    }

    func onAppear() {
        reload()
        startClock()
        // Listen for snooze requests originating from notification actions.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSnoozeRequest(_:)),
            name: .disciplineSnoozeRequested,
            object: nil
        )
    }

    func onDisappear() {
        clockTimer?.invalidate()
        clockTimer = nil
        NotificationCenter.default.removeObserver(self)
    }

    func reload() {
        rules       = ruleUseCases.fetchAll()
        schedule    = scheduleUseCases.fetch()
        activeBlock = scheduleUseCases.activeBlockNow(in: schedule)
    }

    func toggleRule(_ rule: Rule) {
        ruleUseCases.toggleEnabled(rule)
        reload()
    }

    // MARK: - Private

    private func startClock() {
        updateClock()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
    }

    private func updateClock() {
        let fmt        = DateFormatter()
        fmt.timeStyle  = .short
        currentTime    = fmt.string(from: Date())
        activeBlock    = scheduleUseCases.activeBlockNow(in: schedule)
    }

    @objc private func handleSnoozeRequest(_ note: Notification) {
        guard
            let ruleIdStr = note.userInfo?["ruleId"] as? String,
            let ruleId    = UUID(uuidString: ruleIdStr),
            let rule      = rules.first(where: { $0.id == ruleId })
        else { return }

        let template = DependencyContainer.shared.templateUseCases
            .fetchAll()
            .filter { $0.assignedRuleIds.contains(rule.id) || $0.isGlobal }
            .randomElement()

        NotificationManager.shared.scheduleSnoozedNotification(
            for: rule,
            template: template,
            minutes: 5
        )
    }
}
