import Foundation

final class UserDefaultsRuleRepository: RuleRepository {
    private let key = "discipline.rules"

    func fetchAll() -> [Rule] {
        guard
            let data  = UserDefaults.standard.data(forKey: key),
            let rules = try? JSONDecoder().decode([Rule].self, from: data)
        else { return [] }
        return rules
    }

    func save(_ rule: Rule) {
        var rules = fetchAll()
        rules.append(rule)
        persist(rules)
    }

    func update(_ rule: Rule) {
        var rules = fetchAll()
        guard let idx = rules.firstIndex(where: { $0.id == rule.id }) else { return }
        rules[idx] = rule
        persist(rules)
    }

    func delete(id: UUID) {
        var rules = fetchAll()
        rules.removeAll { $0.id == id }
        persist(rules)
    }

    func updateStreak(id: UUID, count: Int, lastViolation: Date?) {
        var rules = fetchAll()
        guard let idx = rules.firstIndex(where: { $0.id == id }) else { return }
        rules[idx].streakCount        = count
        rules[idx].lastViolationDate  = lastViolation
        persist(rules)
    }

    private func persist(_ rules: [Rule]) {
        guard let data = try? JSONEncoder().encode(rules) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
