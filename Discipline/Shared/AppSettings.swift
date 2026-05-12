import Foundation
import Combine

final class AppSettings: ObservableObject {
    @Published var globalCooldownMinutes: Int {
        didSet { UserDefaults.standard.set(globalCooldownMinutes, forKey: StorageKeys.cooldown) }
    }

    init() {
        let saved = UserDefaults.standard.integer(forKey: StorageKeys.cooldown)
        self.globalCooldownMinutes = saved == 0 ? 10 : saved
    }
}
