import Foundation

struct NotificationTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var body: String
    var subtitle: String
    /// Empty = global fallback (applies to all rules).
    var assignedRuleIds: [UUID]

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        subtitle: String = "",
        assignedRuleIds: [UUID] = []
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.subtitle = subtitle
        self.assignedRuleIds = assignedRuleIds
    }

    var isGlobal: Bool { assignedRuleIds.isEmpty }

    static let starterTemplates: [NotificationTemplate] = [
        NotificationTemplate(
            title: "Hey.",
            body: "It’s past your bedtime. You said you’d sleep at this hour. You know what sleep deprivation does to your focus tomorrow. Put the phone down.",
            subtitle: "Sleep boundary"
        ),
        NotificationTemplate(
            title: "Still here?",
            body: "You’ve been scrolling for a while. Nothing meaningful happens on this app at this hour. You know that. Close it.",
            subtitle: "Social media"
        ),
        NotificationTemplate(
            title: "This is the version of you that loses.",
            body: "The disciplined version of you went to sleep an hour ago. Decide which one shows up tomorrow.",
            subtitle: "Late night check"
        ),
        NotificationTemplate(
            title: "One more scroll won’t help.",
            body: "You’ve told yourself that three times. It’s not going to be different this time. You’re better than this habit.",
            subtitle: "Habit reminder"
        ),
        NotificationTemplate(
            title: "Your future self is watching.",
            body: "Right now. This decision. This is the kind of moment that compounds. Make the right call.",
            subtitle: "Discipline check"
        ),
        NotificationTemplate(
            title: "You set this rule for a reason.",
            body: "You knew this moment would come. That’s why you set this reminder. Past you was right. Listen to them.",
            subtitle: "Rule reminder"
        ),
        NotificationTemplate(
            title: "Sleep is a performance drug.",
            body: "Every hour you lose tonight costs you tomorrow in focus, memory, and mood. The math doesn’t lie. Lights out.",
            subtitle: "Sleep science"
        ),
        NotificationTemplate(
            title: "Seriously?",
            body: "It’s late. You have goals. This isn’t aligned with them. You already know this. Stop.",
            subtitle: "Direct check"
        ),
    ]
}
