import Foundation
import Combine

final class ScheduleViewModel: ObservableObject {
    @Published var schedule: Schedule = Schedule()

    private let scheduleUseCases: ScheduleUseCases

    init(scheduleUseCases: ScheduleUseCases = DependencyContainer.shared.scheduleUseCases) {
        self.scheduleUseCases = scheduleUseCases
    }

    func onAppear() {
        schedule = scheduleUseCases.fetch()
    }

    func addBlock(_ block: ScheduleBlock) {
        schedule.blocks.append(block)
        scheduleUseCases.save(schedule)
    }

    func updateBlock(_ block: ScheduleBlock) {
        guard let idx = schedule.blocks.firstIndex(where: { $0.id == block.id }) else { return }
        schedule.blocks[idx] = block
        scheduleUseCases.save(schedule)
    }

    func deleteBlocks(at offsets: IndexSet) {
        schedule.blocks.remove(atOffsets: offsets)
        scheduleUseCases.save(schedule)
    }
}
