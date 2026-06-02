import Foundation

enum TriggerType: Codable, Equatable {
    case timeBased(TimeBasedTrigger)
    case conflictBased(ConflictBasedTrigger)
    /// Requires FamilyControls entitlement — architecture present, gated at runtime.
    case appBased(AppBasedTrigger)
    /// Requires FamilyControls entitlement — architecture present, gated at runtime.
    case durationBased(DurationBasedTrigger)
}

struct TimeBasedTrigger: Codable, Equatable {
    var hour: Int
    var minute: Int
    var repeats: Bool
}

struct ConflictBasedTrigger: Codable, Equatable {
    var conflictingScheduleBlockType: ScheduleBlockType
}

struct AppBasedTrigger: Codable, Equatable {
    var bundleIdentifiers: [String]
}

struct DurationBasedTrigger: Codable, Equatable {
    var appBundleIdentifier: String
    var dailyLimitMinutes: Int
}

extension TriggerType {
    var displaySummary: String {
        switch self {
        case .timeBased(let t):
            return String(format: "Daily at %02d:%02d", t.hour, t.minute)
        case .conflictBased(let t):
            return "Conflict with \(t.conflictingScheduleBlockType.displayName)"
        case .appBased:
            return "App launch (requires Screen Time)"
        case .durationBased(let t):
            return "After \(t.dailyLimitMinutes)min/day (requires Screen Time)"
        }
    }
}
