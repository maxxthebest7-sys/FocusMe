import Foundation

protocol ScheduleRepository {
    func fetch() -> Schedule
    func save(_ schedule: Schedule)
}
