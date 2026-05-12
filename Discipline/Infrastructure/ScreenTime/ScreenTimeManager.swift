import Foundation

/// Screen Time features (app monitoring, duration limits) require the
/// FamilyControls entitlement from Apple.
///
/// **To activate after obtaining a paid developer account:**
/// 1. Enable the FamilyControls capability in your target’s Signing & Capabilities.
/// 2. Submit a request to Apple for the FamilyControls entitlement (required).
/// 3. Add the following entitlements to your .entitlements file:
///    `com.apple.developer.family-controls`
/// 4. Import FamilyControls, DeviceActivity, and ManagedSettings.
/// 5. Replace the stub bodies below with real API calls.
///
/// Without the entitlement, calling FamilyControls APIs crashes immediately.
/// This manager guards every call behind `isAvailable` so the app stays
/// stable on free provisioning.
final class ScreenTimeManager {
    static let shared = ScreenTimeManager()

    /// False until the FamilyControls entitlement is provisioned.
    private(set) var isAvailable: Bool = false

    private init() {
        // Entitlement presence would be detected here via a try/catch on
        // AuthorizationCenter.shared.requestAuthorization in a sandbox build.
        isAvailable = false
    }

    /// Prompt the user for Screen Time authorization.
    func requestAuthorization(completion: @escaping (Result<Void, Error>) -> Void) {
        guard isAvailable else {
            completion(.failure(ScreenTimeError.entitlementNotProvisioned))
            return
        }
        // With entitlement:
        // Task { try await AuthorizationCenter.shared.requestAuthorization(for: .individual) }
    }

    /// Begin monitoring the given bundle identifiers via DeviceActivityCenter.
    func startMonitoring(bundleIdentifiers: [String]) {
        guard isAvailable else { return }
        // Configure DeviceActivitySchedule + DeviceActivityCenter here.
    }

    func stopMonitoring() {
        guard isAvailable else { return }
    }
}

enum ScreenTimeError: LocalizedError {
    case entitlementNotProvisioned

    var errorDescription: String? {
        "Screen Time monitoring requires the FamilyControls entitlement. " +
        "See README.md for setup instructions."
    }
}
