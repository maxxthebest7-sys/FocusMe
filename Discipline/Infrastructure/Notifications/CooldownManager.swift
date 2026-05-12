import Foundation

/// Tracks per-rule last-fired timestamps to enforce notification cooldowns.
final class CooldownManager {
    static let shared = CooldownManager()
    private let key   = "discipline.cooldown.lastFired"

    private init() {}

    func canFire(rule: Rule) -> Bool {
        let cooldown = TimeInterval(rule.cooldownMinutes * 60)
        guard let last = lastFiredDate(for: rule) else { return true }
        return Date().timeIntervalSince(last) >= cooldown
    }

    func recordFired(rule: Rule) {
        var dict = loadDict()
        dict[rule.id.uuidString] = Date()
        saveDict(dict)
    }

    // MARK: - Private

    private func lastFiredDate(for rule: Rule) -> Date? {
        loadDict()[rule.id.uuidString]
    }

    private func loadDict() -> [String: Date] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let dict = try? JSONDecoder().decode([String: Date].self, from: data)
        else { return [:] }
        return dict
    }

    private func saveDict(_ dict: [String: Date]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
