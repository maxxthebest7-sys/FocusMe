import Foundation

final class CooldownManager {
    static let shared = CooldownManager()
    private init() {}

    func canFire(rule: Rule) -> Bool {
        let globalMinutes = UserDefaults.standard.integer(forKey: StorageKeys.cooldown)
        let effective = max(rule.cooldownMinutes, globalMinutes == 0 ? 10 : globalMinutes)
        let cooldown = TimeInterval(effective * 60)
        guard let last = lastFiredDate(for: rule) else { return true }
        return Date().timeIntervalSince(last) >= cooldown
    }

    func recordFired(rule: Rule) {
        var dict = loadDict()
        dict[rule.id.uuidString] = Date()
        saveDict(dict)
    }

    private func lastFiredDate(for rule: Rule) -> Date? {
        loadDict()[rule.id.uuidString]
    }

    private func loadDict() -> [String: Date] {
        guard
            let data = UserDefaults.standard.data(forKey: StorageKeys.cooldownFired),
            let dict = try? JSONDecoder().decode([String: Date].self, from: data)
        else { return [:] }
        return dict
    }

    private func saveDict(_ dict: [String: Date]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: StorageKeys.cooldownFired)
    }
}
