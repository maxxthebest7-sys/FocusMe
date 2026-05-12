import Foundation

struct Rule: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var triggerType: TriggerType
    var monitoredApps: [MonitoredApp]
    var activeDays: Set<DayOfWeek>
    var isEnabled: Bool
    var cooldownMinutes: Int
    var templateIds: [UUID]
    var streakCount: Int
    var lastViolationDate: Date?

    init(
        id: UUID = UUID(),
        name: String,
        triggerType: TriggerType,
        monitoredApps: [MonitoredApp] = [],
        activeDays: Set<DayOfWeek> = Set(DayOfWeek.allCases),
        isEnabled: Bool = true,
        cooldownMinutes: Int = 10,
        templateIds: [UUID] = [],
        streakCount: Int = 0,
        lastViolationDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.triggerType = triggerType
        self.monitoredApps = monitoredApps
        self.activeDays = activeDays
        self.isEnabled = isEnabled
        self.cooldownMinutes = cooldownMinutes
        self.templateIds = templateIds
        self.streakCount = streakCount
        self.lastViolationDate = lastViolationDate
    }
}
