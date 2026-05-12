import SwiftUI

enum TemplateFormMode {
    case add
    case edit(NotificationTemplate)

    var navigationTitle: String {
        switch self { case .add: return "New Message"; case .edit: return "Edit Message" }
    }
}

struct AddEditTemplateView: View {
    let mode:   TemplateFormMode
    let onSave: (NotificationTemplate) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var rulesVM = RulesViewModel()

    @State private var title:           String      = ""
    @State private var subtitle:        String      = ""
    @State private var body:            String      = ""
    @State private var isGlobal:        Bool        = true
    @State private var selectedRuleIds: Set<UUID>   = []

    init(mode: TemplateFormMode, onSave: @escaping (NotificationTemplate) -> Void) {
        self.mode   = mode
        self.onSave = onSave
        guard case .edit(let t) = mode else { return }
        _title          = State(initialValue: t.title)
        _subtitle       = State(initialValue: t.subtitle)
        _body           = State(initialValue: t.body)
        _isGlobal       = State(initialValue: t.isGlobal)
        _selectedRuleIds = State(initialValue: Set(t.assignedRuleIds))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Notification Title") {
                    TextField("e.g. Hey.", text: $title)
                        .foregroundColor(DS.textPrimary)
                }
                .listRowBackground(DS.surface)

                Section("Subtitle  (optional)") {
                    TextField("e.g. Sleep boundary", text: $subtitle)
                        .foregroundColor(DS.textPrimary)
                }
                .listRowBackground(DS.surface)

                Section("Message Body") {
                    TextEditor(text: $body)
                        .foregroundColor(DS.textPrimary)
                        .frame(minHeight: 120)
                        .background(DS.surface)
                }
                .listRowBackground(DS.surface)

                Section("Assignment") {
                    Toggle("Global fallback (used by all rules)", isOn: $isGlobal)
                        .foregroundColor(DS.textPrimary)
                        .toggleStyle(SwitchToggleStyle(tint: DS.accent))

                    if !isGlobal {
                        if rulesVM.rules.isEmpty {
                            Text("No rules yet — create one first.")
                                .font(DS.Font.caption)
                                .foregroundColor(DS.textSecondary)
                        } else {
                            ForEach(rulesVM.rules) { rule in
                                Button {
                                    if selectedRuleIds.contains(rule.id) {
                                        selectedRuleIds.remove(rule.id)
                                    } else {
                                        selectedRuleIds.insert(rule.id)
                                    }
                                } label: {
                                    HStack {
                                        Text(rule.name)
                                            .foregroundColor(DS.textPrimary)
                                        Spacer()
                                        if selectedRuleIds.contains(rule.id) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(DS.accent)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listRowBackground(DS.surface)
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
                        .disabled(
                            title.trimmingCharacters(in: .whitespaces).isEmpty ||
                            body.trimmingCharacters(in: .whitespaces).isEmpty
                        )
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { rulesVM.onAppear() }
    }

    private func saveAndDismiss() {
        let id: UUID = { if case .edit(let t) = mode { return t.id } else { return UUID() } }()
        let template = NotificationTemplate(
            id: id,
            title:   title.trimmingCharacters(in: .whitespaces),
            body:    body.trimmingCharacters(in: .whitespaces),
            subtitle: subtitle.trimmingCharacters(in: .whitespaces),
            assignedRuleIds: isGlobal ? [] : Array(selectedRuleIds)
        )
        onSave(template)
        dismiss()
    }
}
