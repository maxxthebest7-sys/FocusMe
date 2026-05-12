import Foundation

final class UserDefaultsTemplateRepository: TemplateRepository {
    private let key = "discipline.templates"

    func fetchAll() -> [NotificationTemplate] {
        guard
            let data      = UserDefaults.standard.data(forKey: key),
            let templates = try? JSONDecoder().decode([NotificationTemplate].self, from: data)
        else { return [] }
        return templates
    }

    func save(_ template: NotificationTemplate) {
        var templates = fetchAll()
        templates.append(template)
        persist(templates)
    }

    func update(_ template: NotificationTemplate) {
        var templates = fetchAll()
        guard let idx = templates.firstIndex(where: { $0.id == template.id }) else { return }
        templates[idx] = template
        persist(templates)
    }

    func delete(id: UUID) {
        var templates = fetchAll()
        templates.removeAll { $0.id == id }
        persist(templates)
    }

    private func persist(_ templates: [NotificationTemplate]) {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
