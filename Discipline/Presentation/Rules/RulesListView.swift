import SwiftUI

struct RulesListView: View {
    @StateObject private var vm = RulesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.rules.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(vm.rules) { rule in
                            NavigationLink {
                                AddEditRuleView(mode: .edit(rule)) { vm.update($0) }
                            } label: {
                                RuleRow(rule: rule) { vm.toggle(rule) }
                            }
                            .listRowBackground(DS.surface)
                            .listRowSeparatorTint(DS.surfaceBorder)
                        }
                        .onDelete { vm.delete($0) }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black.ignoresSafeArea())
                }
            }
            .navigationTitle("Rules")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { vm.showAddRule = true } label: {
                        Image(systemName: "plus").foregroundColor(DS.accent)
                    }
                }
            }
            .sheet(isPresented: $vm.showAddRule) {
                AddEditRuleView(mode: .add) { vm.add($0) }
            }
        }
        .onAppear { vm.onAppear() }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Space.lg) {
            Image(systemName: "shield.slash")
                .font(.system(size: 52))
                .foregroundColor(DS.textTertiary)
            Text("No rules yet.")
                .font(DS.Font.titleBold)
                .foregroundColor(DS.textPrimary)
            Text("Add your first rule to start enforcing discipline.")
                .font(DS.Font.body)
                .foregroundColor(DS.textSecondary)
                .multilineTextAlignment(.center)
            Button("Add Rule") { vm.showAddRule = true }
                .foregroundColor(DS.accent)
                .font(DS.Font.headline)
        }
        .padding(DS.Space.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Rule row

struct RuleRow: View {
    let rule:     Rule
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: DS.Space.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.name)
                    .font(DS.Font.headline)
                    .foregroundColor(rule.isEnabled ? DS.textPrimary : DS.textSecondary)

                Text(rule.triggerType.displaySummary)
                    .font(DS.Font.caption)
                    .foregroundColor(DS.textSecondary)

                // Active-days indicator
                HStack(spacing: 3) {
                    ForEach(DayOfWeek.allCases) { day in
                        Text(day.singleLetter)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(
                                rule.activeDays.contains(day) ? DS.accent : DS.textTertiary
                            )
                    }
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(SwitchToggleStyle(tint: DS.accent))
            .labelsHidden()
        }
        .padding(.vertical, 6)
    }
}
