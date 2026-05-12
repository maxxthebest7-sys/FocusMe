import SwiftUI

@main
struct DisciplineApp: App {
    @StateObject private var appSettings = AppSettings()

    init() {
        NotificationManager.shared.requestAuthorization { _ in }
        DependencyContainer.shared.templateUseCases.seedStarterTemplates()
        BackgroundTaskManager.shared.registerTasks()
        BackgroundTaskManager.shared.scheduleNextEvaluation()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appSettings)
                .preferredColorScheme(.dark)
        }
    }
}
