import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var cooldownMinutes: Int

    private let ruleRepository:     RuleRepository
    private let templateRepository: TemplateRepository

    init(
        ruleRepository:     RuleRepository     = DependencyContainer.shared.ruleRepository,
        templateRepository: TemplateRepository = DependencyContainer.shared.templateRepository
    ) {
        self.ruleRepository     = ruleRepository
        self.templateRepository = templateRepository
        let saved               = UserDefaults.standard.integer(forKey: StorageKeys.cooldown)
        self.cooldownMinutes    = saved == 0 ? 10 : saved
    }

    func saveCooldown() {
        UserDefaults.standard.set(cooldownMinutes, forKey: StorageKeys.cooldown)
    }

    // MARK: - Export / Import

    func exportRulesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(ruleRepository.fetchAll()) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func importRulesJSON(_ json: String) {
        guard
            let data  = json.data(using: .utf8),
            let rules = try? JSONDecoder().decode([Rule].self, from: data)
        else { return }
        let existing = Set(ruleRepository.fetchAll().map(\.id))
        rules.filter { !existing.contains($0.id) }.forEach { ruleRepository.save($0) }
    }

    func exportTemplatesJSON() -> String? {
        guard let data = try? JSONEncoder().encode(templateRepository.fetchAll()) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
