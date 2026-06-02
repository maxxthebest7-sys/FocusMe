import Foundation

protocol TemplateRepository {
    func fetchAll() -> [NotificationTemplate]
    func save(_ template: NotificationTemplate)
    func update(_ template: NotificationTemplate)
    func delete(id: UUID)
}
