import Foundation

final class UserDefaultsScheduleRepository: ScheduleRepository {
    private let key = "discipline.schedule"

    func fetch() -> Schedule {
        guard
            let data     = UserDefaults.standard.data(forKey: key),
            let schedule = try? JSONDecoder().decode(Schedule.self, from: data)
        else { return .defaultSchedule }
        return schedule
    }

    func save(_ schedule: Schedule) {
        guard let data = try? JSONEncoder().encode(schedule) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
