import Foundation
import Combine

final class AppSettings: ObservableObject {
    @Published var globalCooldownMinutes: Int {
        didSet { UserDefaults.standard.set(globalCooldownMinutes, forKey: Keys.cooldown) }
    }

    init() {
        let saved = UserDefaults.standard.integer(forKey: Keys.cooldown)
        self.globalCooldownMinutes = saved == 0 ? 10 : saved
    }

    private enum Keys {
        static let cooldown = "discipline.settings.cooldown"
    }
}
