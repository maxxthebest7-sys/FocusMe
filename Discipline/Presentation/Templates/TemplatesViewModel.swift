import Foundation
import Combine

final class TemplatesViewModel: ObservableObject {
    @Published var templates:        [NotificationTemplate] = []
    @Published var showAddTemplate:  Bool                   = false

    private let templateUseCases: TemplateUseCases

    init(templateUseCases: TemplateUseCases = DependencyContainer.shared.templateUseCases) {
        self.templateUseCases = templateUseCases
    }

    func onAppear() { reload() }

    func reload() {
        templates = templateUseCases.fetchAll()
    }

    func add(_ template: NotificationTemplate) {
        templateUseCases.add(template)
        reload()
    }

    func update(_ template: NotificationTemplate) {
        templateUseCases.update(template)
        reload()
    }

    func delete(_ offsets: IndexSet) {
        let toDelete = offsets.map { templates[$0] }
        toDelete.forEach { templateUseCases.delete(id: $0.id) }
        reload()
    }
}
