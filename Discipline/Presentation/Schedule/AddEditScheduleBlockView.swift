import SwiftUI

enum ScheduleBlockFormMode {
    case add
    case edit(ScheduleBlock)

    var navigationTitle: String {
        switch self { case .add: return "New Block"; case .edit: return "Edit Block" }
    }
}

struct AddEditScheduleBlockView: View {
    let mode:   ScheduleBlockFormMode
    let onSave: (ScheduleBlock) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var label:       String            = ""
    @State private var blockType:   ScheduleBlockType = .sleep
    @State private var startHour:   Int               = 23
    @State private var startMinute: Int               = 0
    @State private var endHour:     Int               = 7
    @State private var endMinute:   Int               = 0

    init(mode: ScheduleBlockFormMode, onSave: @escaping (ScheduleBlock) -> Void) {
        self.mode   = mode
        self.onSave = onSave
        guard case .edit(let b) = mode else { return }
        _label       = State(initialValue: b.label)
        _blockType   = State(initialValue: b.type)
        _startHour   = State(initialValue: b.startHour)
        _startMinute = State(initialValue: b.startMinute)
        _endHour     = State(initialValue: b.endHour)
        _endMinute   = State(initialValue: b.endMinute)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Label") {
                    TextField("e.g. Sleep, Deep Work", text: $label)
                        .foregroundColor(DS.textPrimary)
                }
                .listRowBackground(DS.surface)

                Section("Type") {
                    Picker("Block type", selection: $blockType) {
                        ForEach(ScheduleBlockType.allCases, id: \.self) { t in
                            Label(t.displayName, systemImage: t.sfSymbol).tag(t)
                        }
                    }
                    .foregroundColor(DS.textPrimary)
                }
                .listRowBackground(DS.surface)

                Section("Start Time") {
                    timePicker(hour: $startHour, minute: $startMinute)
                }
                .listRowBackground(DS.surface)

                Section("End Time") {
                    timePicker(hour: $endHour, minute: $endMinute)
                }
                .listRowBackground(DS.surface)

                if startHour > endHour || (startHour == endHour && startMinute >= endMinute) {
                    Section {
                        HStack(spacing: DS.Space.sm) {
                            Image(systemName: "moon.fill").foregroundColor(DS.accent)
                            Text("Overnight block — wraps past midnight.")
                                .font(DS.Font.caption)
                                .foregroundColor(DS.textSecondary)
                        }
                    }
                    .listRowBackground(DS.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(mode.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(DS.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAndDismiss() }
                        .foregroundColor(DS.accent)
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func timePicker(hour: Binding<Int>, minute: Binding<Int>) -> some View {
        HStack {
            Picker("H", selection: hour) {
                ForEach(0..<24) { h in Text(String(format: "%02d", h)).tag(h) }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity, maxHeight: 110)

            Text(":")
                .font(DS.Font.titleBold)
                .foregroundColor(DS.textSecondary)

            Picker("M", selection: minute) {
                ForEach([0, 15, 30, 45], id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity, maxHeight: 110)
        }
    }

    private func saveAndDismiss() {
        let id: UUID = { if case .edit(let b) = mode { return b.id } else { return UUID() } }()
        let block = ScheduleBlock(
            id: id,
            type: blockType,
            label: label.trimmingCharacters(in: .whitespaces).isEmpty ? blockType.displayName : label,
            startHour:   startHour,
            startMinute: startMinute,
            endHour:     endHour,
            endMinute:   endMinute
        )
        onSave(block)
        dismiss()
    }
}
