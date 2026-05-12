import Foundation

final class ScheduleUseCases {
    private let repository: ScheduleRepository

    init(repository: ScheduleRepository) {
        self.repository = repository
    }

    func fetch() -> Schedule {
        repository.fetch()
    }

    func save(_ schedule: Schedule) {
        repository.save(schedule)
    }

    func activeBlockNow(in schedule: Schedule) -> ScheduleBlock? {
        let cal    = Calendar.current
        let now    = Date()
        let hour   = cal.component(.hour,   from: now)
        let minute = cal.component(.minute, from: now)
        return schedule.blocks.first { $0.isActive(hour: hour, minute: minute) }
    }
}
