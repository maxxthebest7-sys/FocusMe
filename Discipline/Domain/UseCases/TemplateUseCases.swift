import Foundation

final class TemplateUseCases {
    private let repository: TemplateRepository

    init(repository: TemplateRepository) {
        self.repository = repository
    }

    func fetchAll() -> [NotificationTemplate] {
        repository.fetchAll()
    }

    func add(_ template: NotificationTemplate) {
        repository.save(template)
    }

    func update(_ template: NotificationTemplate) {
        repository.update(template)
    }

    func delete(id: UUID) {
        repository.delete(id: id)
    }

    /// Seeds starter message templates on first launch.
    func seedStarterTemplates() {
        guard repository.fetchAll().isEmpty else { return }
        NotificationTemplate.starterTemplates.forEach { repository.save($0) }
    }
}
