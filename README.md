# Discipline

A native SwiftUI iOS app that acts as a personal authority figure — enforcing your self-imposed behavioral rules through local notifications. No accounts, no cloud, no gamification. Just a clean rule engine and messages that sound like your future self wrote them.

---

## Repo Assessment

| Repo | Decision | Reason |
|---|---|---|
| **FocusMe** | ✅ Extended | Only native iOS SwiftUI app in the list. Already had clean architecture (App / Domain / Data / Infrastructure / Presentation), a working `NotificationManager`, CoreData, and MVVM. Direct overlap with every feature required. |
| alarmer | ❌ | Android / Kotlin (Gradle build system). |
| Kairos-Pomodoro | ❌ | Tauri + Vite web app. |
| screen-time-api-agent-skill | ❌ | Claude Code skill definition (markdown). |
| local-notifications | ℹ️ | Swift library with XcodeGen `project.yml`. Adopted its XcodeGen approach for this project. |
| everything-claude-code | ❌ | JavaScript tooling repo. |
| RemoteWorkTracker, MonoTimer, Pomodoro-Timer, open-source-ios-apps, activitywatch | ❌ | Wrong platform, language, or domain. |

**FocusMe's** existing infrastructure (`NotificationManager`, clean-architecture layers, CoreData patterns) gave a ~30% head start. The Discipline app replaces the `Reminder` domain entirely with a `Rule` + `NotificationTemplate` + `Schedule` domain designed for behavioral enforcement.

---

## Setup

### Prerequisites

- macOS 13+ with Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — generates the `.xcodeproj` from `project.yml`
- A free Apple ID (for Simulator and direct device testing via personal provisioning)

### First-time setup

```bash
# 1. Clone
git clone https://github.com/maxxthebest7-sys/FocusMe.git
cd FocusMe
git checkout claude/ios-discipline-app-JLm0t

# 2. Install XcodeGen (if you haven't already)
brew install xcodegen

# 3. Generate the Xcode project
xcodegen generate

# 4. Open in Xcode
open Discipline.xcodeproj
```

### Building

1. In Xcode, select the **Discipline** scheme.
2. Choose a Simulator or your connected iPhone.
3. Set your personal team in **Signing & Capabilities** → Team.
4. Press ⌘R.

All time-based and conflict-based rules, notifications, schedules, and message templates work immediately on a free provisioning profile.

---

## Architecture

```
Discipline/
├── App/                        # @main entry point, app lifecycle
├── Domain/
│   ├── Entities/               # Rule, Schedule, NotificationTemplate, TriggerType, ...
│   ├── Repositories/           # Protocol definitions (RuleRepository, etc.)
│   └── UseCases/               # RuleEngine, RuleUseCases, ScheduleUseCases, ...
├── Data/
│   └── Repositories/           # UserDefaults-backed Codable implementations
├── Infrastructure/
│   ├── Notifications/          # NotificationManager (UNUserNotificationCenter)
│   │                           # CooldownManager (per-rule cooldown enforcement)
│   ├── BackgroundTasks/        # BGTaskScheduler registration + rule evaluation
│   └── ScreenTime/             # ScreenTimeManager stub (gated — see below)
├── Shared/
│   ├── AppSettings.swift       # ObservableObject for global user preferences
│   └── DependencyContainer.swift  # Simple singleton DI container
└── Presentation/
    ├── Dashboard/              # Today view: active block, rules, streaks
    ├── Rules/                  # Rule list, add/edit rule form
    ├── Schedule/               # Daily schedule blocks, add/edit block form
    ├── Templates/              # Notification message library, add/edit
    ├── Settings/               # Cooldown, Screen Time info, JSON export/import
    └── Shared/                 # DesignSystem (DS.*), MainTabView, DayPickerRow
```

**Pattern:** MVVM throughout. The `RuleEngine` lives in Domain/UseCases and is injected with protocol dependencies — it can be unit tested independently with mock repositories.

**Persistence:** All data is stored via `UserDefaults` as JSON (`Codable`). No Core Data model file is required, making the project fully portable via GitHub API. Data never leaves the device.

---

## Features

### Rule Engine
- **Time-based:** fires a notification at a specific hour:minute every day (or once).
- **Conflict-based:** fires when the current time falls inside a schedule block you're supposed to be off your phone (e.g., using Instagram during Sleep hours).
- **App-based / Duration-based:** architecture is complete; gated behind Screen Time entitlement (see below).
- **Per-rule cooldown:** configurable (default 10 min). Won't spam you.
- **Active days:** toggle which days of the week each rule applies.

### Notification Template Library
- Write your own messages — or use the 8 starter templates loaded on first launch.
- Each message has a title, subtitle, and body.
- Assign messages to specific rules, or mark them **global** (used as fallback for any rule).
- Multiple messages per rule: one is chosen at random each time the rule fires.
- Notifications arrive with two action buttons: **"I'll stop now"** and **"Give me 5 more minutes"** (snoozes and re-notifies).

### Personal Schedule
- Define sleep, study, workout, work, and free-time blocks.
- Overnight blocks (e.g., Sleep: 23:00–07:00) are handled correctly.
- Conflict-based rules reference these blocks.

### Dashboard
- Current active schedule block.
- All rules with live enable/disable toggles.
- Streak tracker (days without a violation per rule).

### Settings
- Global notification cooldown control.
- Export rules and message templates as JSON.
- Import rules from JSON (for backup restore).
- Open notification system settings directly.

---

## Screen Time API (FamilyControls)

App-based and duration-based rule triggers require Apple's **FamilyControls** entitlement.

### Current state
`ScreenTimeManager` is fully architected but all methods are gated behind `isAvailable = false`. The app runs stably without the entitlement.

### Activating Screen Time features

1. **Get a paid Apple Developer account** ($99/year at developer.apple.com).
2. **Request the FamilyControls entitlement** from Apple — this requires submitting a request at [developer.apple.com/contact/request/family-controls-distribution](https://developer.apple.com/contact/request/family-controls-distribution).
3. In Xcode: **Target → Signing & Capabilities → + Capability → Family Controls**.
4. In `ScreenTimeManager.swift`, set `isAvailable = true` and uncomment the real API calls:
   ```swift
   // requestAuthorization:
   Task { try await AuthorizationCenter.shared.requestAuthorization(for: .individual) }

   // startMonitoring:
   // Configure DeviceActivitySchedule and DeviceActivityCenter
   ```
5. In `AddEditRuleView.swift`, replace the "requires Screen Time" info label with `FamilyActivityPicker` for visual app selection.

---

## Known limitations (free provisioning)

| Feature | Status |
|---|---|
| Time-based rules & notifications | ✅ Full support |
| Conflict-based rules | ✅ Full support |
| Background evaluation (BGTaskScheduler) | ✅ Registered; iOS may rate-limit frequency |
| App-launch monitoring | ⚠️ Requires FamilyControls entitlement |
| Duration-based monitoring | ⚠️ Requires FamilyControls entitlement |
| App Store distribution | ⚠️ Requires paid developer account |

Background tasks run at iOS's discretion — for reliable nightly enforcement, **time-based rules** (which use `UNCalendarNotificationTrigger` scheduled ahead of time) are the most reliable trigger type and don't depend on BGTaskScheduler at all.

---

## Credits

Built on [FocusMe](https://github.com/maxxthebest7-sys/FocusMe) by Rodrigo Porto (MIT License). XcodeGen project structure inspired by [local-notifications-unusernotificationcenter](https://github.com/maxxthebest7-sys/local-notifications-unusernotificationcenter).
