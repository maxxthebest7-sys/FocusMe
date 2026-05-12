import Foundation

protocol RuleRepository {
    func fetchAll() -> [Rule]
    func save(_ rule: Rule)
    func update(_ rule: Rule)
    func delete(id: UUID)
    func updateStreak(id: UUID, count: Int, lastViolation: Date?)
}
