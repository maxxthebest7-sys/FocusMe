import Foundation

struct Schedule: Codable, Equatable {
    var blocks: [ScheduleBlock]

    init(blocks: [ScheduleBlock] = []) {
        self.blocks = blocks
    }

    static var defaultSchedule: Schedule {
        Schedule(blocks: [
            ScheduleBlock(type: .sleep,   label: "Sleep",   startHour: 23, startMinute: 0, endHour: 7,  endMinute: 0),
            ScheduleBlock(type: .study,   label: "Study",   startHour: 9,  startMinute: 0, endHour: 12, endMinute: 0),
            ScheduleBlock(type: .workout, label: "Workout", startHour: 17, startMinute: 0, endHour: 18, endMinute: 0),
        ])
    }
}

struct ScheduleBlock: Identifiable, Codable, Equatable {
    let id: UUID
    var type: ScheduleBlockType
    var label: String
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int

    init(
        id: UUID = UUID(),
        type: ScheduleBlockType,
        label: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int
    ) {
        self.id = id
        self.type = type
        self.label = label
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }

    var startTimeString: String { String(format: "%02d:%02d", startHour, startMinute) }
    var endTimeString: String   { String(format: "%02d:%02d", endHour,   endMinute)   }

    /// True if the given hour/minute falls within this block.
    /// Handles overnight blocks (e.g. Sleep: 23:00–07:00).
    func isActive(hour: Int, minute: Int) -> Bool {
        let now   = hour * 60 + minute
        let start = startHour * 60 + startMinute
        let end   = endHour   * 60 + endMinute
        if start <= end {
            return now >= start && now < end
        } else {
            return now >= start || now < end
        }
    }
}

enum ScheduleBlockType: String, Codable, CaseIterable {
    case sleep    = "sleep"
    case study    = "study"
    case workout  = "workout"
    case work     = "work"
    case freeTime = "free_time"
    case custom   = "custom"

    var displayName: String {
        switch self {
        case .sleep:    return "Sleep"
        case .study:    return "Study"
        case .workout:  return "Workout"
        case .work:     return "Work"
        case .freeTime: return "Free Time"
        case .custom:   return "Custom"
        }
    }

    var sfSymbol: String {
        switch self {
        case .sleep:    return "moon.fill"
        case .study:    return "book.fill"
        case .workout:  return "figure.run"
        case .work:     return "laptopcomputer"
        case .freeTime: return "sun.max.fill"
        case .custom:   return "pencil"
        }
    }
}
