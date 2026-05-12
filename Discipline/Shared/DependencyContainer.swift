import Foundation

/// Simple dependency container — no third-party DI framework needed.
/// All dependencies are singletons for the app lifetime.
final class DependencyContainer {
    static let shared = DependencyContainer()

    let ruleRepository:     RuleRepository
    let scheduleRepository: ScheduleRepository
    let templateRepository: TemplateRepository

    let ruleUseCases:     RuleUseCases
    let scheduleUseCases: ScheduleUseCases
    let templateUseCases: TemplateUseCases

    let ruleEngine: RuleEngine

    private init() {
        ruleRepository     = UserDefaultsRuleRepository()
        scheduleRepository = UserDefaultsScheduleRepository()
        templateRepository = UserDefaultsTemplateRepository()

        ruleUseCases     = RuleUseCases(repository: ruleRepository)
        scheduleUseCases = ScheduleUseCases(repository: scheduleRepository)
        templateUseCases = TemplateUseCases(repository: templateRepository)

        ruleEngine = RuleEngine(
            ruleRepository:      ruleRepository,
            scheduleRepository:  scheduleRepository,
            templateRepository:  templateRepository,
            notificationManager: .shared
        )
    }
}
