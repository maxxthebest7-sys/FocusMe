import Foundation

enum DayOfWeek: Int, Codable, Hashable, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday:    return "Sun"
        case .monday:    return "Mon"
        case .tuesday:   return "Tue"
        case .wednesday: return "Wed"
        case .thursday:  return "Thu"
        case .friday:    return "Fri"
        case .saturday:  return "Sat"
        }
    }

    var singleLetter: String { String(shortName.prefix(1)) }
}
