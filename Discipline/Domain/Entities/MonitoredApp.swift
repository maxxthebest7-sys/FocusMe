import Foundation

struct MonitoredApp: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var bundleIdentifier: String
    var sfSymbol: String

    static let presets: [MonitoredApp] = [
        MonitoredApp(id: UUID(), name: "Instagram",    bundleIdentifier: "com.burbn.instagram",       sfSymbol: "camera"),
        MonitoredApp(id: UUID(), name: "TikTok",       bundleIdentifier: "com.zhiliaoapp.musically",  sfSymbol: "music.note"),
        MonitoredApp(id: UUID(), name: "YouTube",      bundleIdentifier: "com.google.ios.youtube",    sfSymbol: "play.rectangle.fill"),
        MonitoredApp(id: UUID(), name: "Twitter / X",  bundleIdentifier: "com.atebits.Tweetie2",      sfSymbol: "bird.fill"),
        MonitoredApp(id: UUID(), name: "Reddit",       bundleIdentifier: "com.reddit.Reddit",          sfSymbol: "arrow.up.circle.fill"),
        MonitoredApp(id: UUID(), name: "Safari",       bundleIdentifier: "com.apple.mobilesafari",    sfSymbol: "safari.fill"),
        MonitoredApp(id: UUID(), name: "Facebook",     bundleIdentifier: "com.facebook.Facebook",     sfSymbol: "f.circle.fill"),
        MonitoredApp(id: UUID(), name: "Snapchat",     bundleIdentifier: "com.toyopagroup.picaboo",   sfSymbol: "camera.circle.fill"),
        MonitoredApp(id: UUID(), name: "Discord",      bundleIdentifier: "com.hammerandchisel.discord", sfSymbol: "bubble.left.and.bubble.right.fill"),
        MonitoredApp(id: UUID(), name: "LinkedIn",     bundleIdentifier: "com.linkedin.LinkedIn",     sfSymbol: "briefcase.fill"),
    ]
}
