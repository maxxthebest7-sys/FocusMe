import BackgroundTasks
import Foundation

final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    static let taskIdentifier = "com.discipline.app.rule-evaluation"

    private init() {}

    /// Call once from App.init() to register the BGTask handler.
    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            self.handleEvaluationTask(task as! BGAppRefreshTask)
        }
    }

    /// Schedule the next background evaluation. Call after each evaluation completes.
    func scheduleNextEvaluation() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        // BGAppRefreshTask has a system-enforced minimum interval; 15 min is typical.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    // MARK: - Private

    private func handleEvaluationTask(_ task: BGAppRefreshTask) {
        // Always schedule the next evaluation before doing work.
        scheduleNextEvaluation()

        let engine = DependencyContainer.shared.ruleEngine
        engine.evaluateAllRules()

        task.setTaskCompleted(success: true)
    }
}
