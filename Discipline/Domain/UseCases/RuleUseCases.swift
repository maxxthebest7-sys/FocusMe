import Foundation

final class RuleUseCases {
    private let repository: RuleRepository

    init(repository: RuleRepository) {
        self.repository = repository
    }

    func fetchAll() -> [Rule] {
        repository.fetchAll()
    }

    func add(_ rule: Rule) {
        repository.save(rule)
    }

    func update(_ rule: Rule) {
        repository.update(rule)
    }

    func delete(id: UUID) {
        repository.delete(id: id)
    }

    func toggleEnabled(_ rule: Rule) {
        var updated = rule
        updated.isEnabled.toggle()
        repository.update(updated)
    }

    func recordViolation(for rule: Rule) {
        repository.updateStreak(id: rule.id, count: 0, lastViolation: Date())
    }

    func incrementStreak(for rule: Rule) {
        repository.updateStreak(
            id: rule.id,
            count: rule.streakCount + 1,
            lastViolation: rule.lastViolationDate
        )
    }
}
