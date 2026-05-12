import Foundation

final class UserDefaultsRuleRepository: RuleRepository {
    private let queue = DispatchQueue(label: "com.discipline.repo.rules")

    func fetchAll() -> [Rule] {
        queue.sync { _fetchAll() }
    }

    func save(_ rule: Rule) {
        queue.sync {
            var rules = _fetchAll()
            rules.append(rule)
            _persist(rules)
        }
    }

    func update(_ rule: Rule) {
        queue.sync {
            var rules = _fetchAll()
            guard let idx = rules.firstIndex(where: { $0.id == rule.id }) else { return }
            rules[idx] = rule
            _persist(rules)
        }
    }

    func delete(id: UUID) {
        queue.sync {
            var rules = _fetchAll()
            rules.removeAll { $0.id == id }
            _persist(rules)
        }
    }

    func updateStreak(id: UUID, count: Int, lastViolation: Date?) {
        queue.sync {
            var rules = _fetchAll()
            guard let idx = rules.firstIndex(where: { $0.id == id }) else { return }
            rules[idx].streakCount       = count
            rules[idx].lastViolationDate = lastViolation
            _persist(rules)
        }
    }

    private func _fetchAll() -> [Rule] {
        guard
            let data  = UserDefaults.standard.data(forKey: StorageKeys.rules),
            let rules = try? JSONDecoder().decode([Rule].self, from: data)
        else { return [] }
        return rules
    }

    private func _persist(_ rules: [Rule]) {
        guard let data = try? JSONEncoder().encode(rules) else { return }
        UserDefaults.standard.set(data, forKey: StorageKeys.rules)
    }
}
