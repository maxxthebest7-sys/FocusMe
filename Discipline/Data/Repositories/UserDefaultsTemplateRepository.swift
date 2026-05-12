import Foundation

final class UserDefaultsTemplateRepository: TemplateRepository {
    private let queue = DispatchQueue(label: "com.discipline.repo.templates")

    func fetchAll() -> [NotificationTemplate] {
        queue.sync { _fetchAll() }
    }

    func save(_ template: NotificationTemplate) {
        queue.sync {
            var templates = _fetchAll()
            templates.append(template)
            _persist(templates)
        }
    }

    func update(_ template: NotificationTemplate) {
        queue.sync {
            var templates = _fetchAll()
            guard let idx = templates.firstIndex(where: { $0.id == template.id }) else { return }
            templates[idx] = template
            _persist(templates)
        }
    }

    func delete(id: UUID) {
        queue.sync {
            var templates = _fetchAll()
            templates.removeAll { $0.id == id }
            _persist(templates)
        }
    }

    private func _fetchAll() -> [NotificationTemplate] {
        guard
            let data      = UserDefaults.standard.data(forKey: StorageKeys.templates),
            let templates = try? JSONDecoder().decode([NotificationTemplate].self, from: data)
        else { return [] }
        return templates
    }

    private func _persist(_ templates: [NotificationTemplate]) {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        UserDefaults.standard.set(data, forKey: StorageKeys.templates)
    }
}
