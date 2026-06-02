import Foundation

final class UserDefaultsScheduleRepository: ScheduleRepository {
    private let queue = DispatchQueue(label: "com.discipline.repo.schedule")

    func fetch() -> Schedule {
        queue.sync {
            guard
                let data     = UserDefaults.standard.data(forKey: StorageKeys.schedule),
                let schedule = try? JSONDecoder().decode(Schedule.self, from: data)
            else { return .defaultSchedule }
            return schedule
        }
    }

    func save(_ schedule: Schedule) {
        queue.sync {
            guard let data = try? JSONEncoder().encode(schedule) else { return }
            UserDefaults.standard.set(data, forKey: StorageKeys.schedule)
        }
    }
}
