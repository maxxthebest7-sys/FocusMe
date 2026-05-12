import BackgroundTasks
import Foundation

final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    static let taskIdentifier = "com.discipline.app.rule-evaluation"

    private init() {}

    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            self.handleEvaluationTask(task as! BGAppRefreshTask)
        }
    }

    func scheduleNextEvaluation() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handleEvaluationTask(_ task: BGAppRefreshTask) {
        scheduleNextEvaluation()

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        DependencyContainer.shared.ruleEngine.evaluateAllRules()
        task.setTaskCompleted(success: true)
    }
}
