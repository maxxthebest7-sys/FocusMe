import SwiftUI

// MARK: - Mode

enum RuleFormMode {
    case add
    case edit(Rule)

    var navigationTitle: String {
        switch self {
        case .add:  return "New Rule"
        case .edit: return "Edit Rule"
        }
    }
}

// MARK: - View

struct AddEditRuleView: View {
    let mode:   RuleFormMode
    let onSave: (Rule) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name:              String           = ""
    @State private var triggerOption:     TriggerOption    = .timeBased
    @State private var timeHour:          Int              = 22
    @State private var timeMinute:        Int              = 0
    @State private var timeRepeats:       Bool             = true
    @State private var conflictBlockType: ScheduleBlockType = .sleep
    @State private var durationLimit:     Int              = 30
    @State private var activeDays:        Set<DayOfWeek>   = Set(DayOfWeek.allCases)
    @State private var cooldownMinutes:   Int              = 10

    // MARK: Init

    init(mode: RuleFormMode, onSave: @escaping (Rule) -> Void) {
        self.mode   = mode
        self.onSave = onSave
        guard case .edit(let rule) = mode else { return }
        _name            = State(initialValue: rule.name)
        _activeDays      = State(initialValue: rule.activeDays)
        _cooldownMinutes = State(initialValue: rule.cooldownMinutes)
        switch rule.triggerType {
        case .timeBased(let t):
            _triggerOption = State(initialValue: .timeBased)
            _timeHour      = State(initialValue: t.hour)
            _timeMinute    = State(initialValue: t.minute)
            _timeRepeats   = State(initialValue: t.repeats)
        case .conflictBased(let t):
            _triggerOption    = State(initialValue: .conflictBased)
            _conflictBlockType = State(initialValue: t.conflictingScheduleBlockType)
        case .appBased:
            _triggerOption = State(initialValue: .appBased)
        case .durationBased(let t):
            _triggerOption  = State(initialValue: .durationBased)
            _durationLimit  = State(initialValue: t.dailyLimitMinutes)
        }
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                triggerSection
                triggerConfigSection
                daysSection
                cooldownSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(mode.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DS.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAndDismiss() }
                        .foregroundColor(DS.accent)
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Form sections

    private var nameSection: some View {
        Section("Rule Name") {
            TextField("e.g. No Instagram after 10pm", text: $name)
                .foregroundColor(DS.textPrimary)
        }
        .listRowBackground(DS.surface)
    }

    private var triggerSection: some View {
        Section("Trigger Type") {
            Picker("Type", selection: $triggerOption) {
                ForEach(TriggerOption.allCases, id: \.self) { opt in
                    Text(opt.label).tag(opt)
                }
            }
            .foregroundColor(DS.textPrimary)
        }
        .listRowBackground(DS.surface)
    }

    @ViewBuilder
    private var triggerConfigSection: some View {
        switch triggerOption {
        case .timeBased:
            Section("Fire At") {
                HStack {
                    Picker("Hour", selection: $timeHour) {
                        ForEach(0..<24) { h in
                            Text(String(format: "%02d", h)).tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity, maxHeight: 110)

                    Text(":")
                        .font(DS.Font.titleBold)
                        .foregroundColor(DS.textSecondary)

                    Picker("Minute", selection: $timeMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text(String(format: "%02d", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity, maxHeight: 110)
                }

                Toggle("Repeat daily", isOn: $timeRepeats)
                    .foregroundColor(DS.textPrimary)
                    .toggleStyle(SwitchToggleStyle(tint: DS.accent))
            }
            .listRowBackground(DS.surface)

        case .conflictBased:
            Section("Conflicts With Schedule Block") {
                Picker("Block type", selection: $conflictBlockType) {
                    ForEach(ScheduleBlockType.allCases, id: \.self) { t in
                        Label(t.displayName, systemImage: t.sfSymbol).tag(t)
                    }
                }
                .foregroundColor(DS.textPrimary)
            }
            .listRowBackground(DS.surface)

        case .appBased, .durationBased:
            Section {
                HStack(alignment: .top, spacing: DS.Space.sm) {
                    Image(systemName: "info.circle").foregroundColor(DS.warning)
                    Text("This trigger type requires the FamilyControls entitlement (paid Apple Developer account + Apple approval). The rule will be saved and activate once provisioned.")
                        .font(DS.Font.caption)
                        .foregroundColor(DS.textSecondary)
                }
                if triggerOption == .durationBased {
                    Stepper("Daily limit: \(durationLimit) min", value: $durationLimit, in: 5...480, step: 5)
                        .foregroundColor(DS.textPrimary)
                }
            }
            .listRowBackground(DS.surface)
        }
    }

    private var daysSection: some View {
        Section("Active Days") {
            DayPickerRow(activeDays: $activeDays)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listRowBackground(DS.surface)
    }

    private var cooldownSection: some View {
        Section("Notification Cooldown") {
            Stepper("\(cooldownMinutes) minutes between alerts",
                    value: $cooldownMinutes, in: 1...120)
                .foregroundColor(DS.textPrimary)
        }
        .listRowBackground(DS.surface)
    }

    // MARK: - Save

    private func saveAndDismiss() {
        let trigger: TriggerType
        switch triggerOption {
        case .timeBased:
            trigger = .timeBased(TimeBasedTrigger(hour: timeHour, minute: timeMinute, repeats: timeRepeats))
        case .conflictBased:
            trigger = .conflictBased(ConflictBasedTrigger(conflictingScheduleBlockType: conflictBlockType))
        case .appBased:
            trigger = .appBased(AppBasedTrigger(bundleIdentifiers: []))
        case .durationBased:
            trigger = .durationBased(DurationBasedTrigger(appBundleIdentifier: "", dailyLimitMinutes: durationLimit))
        }

        let id: UUID = { if case .edit(let r) = mode { return r.id } else { return UUID() } }()

        let rule = Rule(
            id: id,
            name: name.trimmingCharacters(in: .whitespaces),
            triggerType: trigger,
            activeDays: activeDays,
            isEnabled: true,
            cooldownMinutes: cooldownMinutes
        )
        onSave(rule)
        dismiss()
    }
}

// MARK: - Trigger option enum

enum TriggerOption: String, CaseIterable {
    case timeBased     = "timeBased"
    case conflictBased = "conflictBased"
    case appBased      = "appBased"
    case durationBased = "durationBased"

    var label: String {
        switch self {
        case .timeBased:     return "Time-Based"
        case .conflictBased: return "Schedule Conflict"
        case .appBased:      return "App Launch (Screen Time)"
        case .durationBased: return "App Duration (Screen Time)"
        }
    }
}
