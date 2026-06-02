import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    currentStatusCard
                    rulesSection
                    streakSection
                }
                .padding(DS.Space.md)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Discipline")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(vm.currentTime)
                        .font(DS.Font.mono)
                        .foregroundColor(DS.textSecondary)
                }
            }
        }
        .onAppear  { vm.onAppear()    }
        .onDisappear { vm.onDisappear() }
    }

    // MARK: - Current status

    private var currentStatusCard: some View {
        Group {
            if let block = vm.activeBlock {
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: block.type.sfSymbol)
                        .foregroundColor(DS.accent)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Now: \(block.label)")
                            .font(DS.Font.headline)
                            .foregroundColor(DS.textPrimary)
                        Text("\(block.startTimeString) – \(block.endTimeString)")
                            .font(DS.Font.caption)
                            .foregroundColor(DS.textSecondary)
                    }
                    Spacer()
                }
            } else {
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: "circle.dotted")
                        .foregroundColor(DS.textTertiary)
                    Text("No active schedule block")
                        .font(DS.Font.headline)
                        .foregroundColor(DS.textSecondary)
                }
            }
        }
        .card()
    }

    // MARK: - Active rules

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("RULES")
                .sectionHeader()

            if vm.rules.isEmpty {
                Text("No rules yet. Add one in the Rules tab.")
                    .font(DS.Font.body)
                    .foregroundColor(DS.textSecondary)
                    .card()
            } else {
                ForEach(vm.rules) { rule in
                    DashboardRuleRow(rule: rule) { vm.toggleRule(rule) }
                }
            }
        }
    }

    // MARK: - Streaks

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            Text("STREAKS")
                .sectionHeader()

            let streaking = vm.rules.filter { $0.streakCount > 0 }
            if streaking.isEmpty {
                Text("Survive a full day without a violation to start a streak.")
                    .font(DS.Font.body)
                    .foregroundColor(DS.textSecondary)
                    .card()
            } else {
                ForEach(streaking) { rule in
                    HStack {
                        Text(rule.name)
                            .font(DS.Font.body)
                            .foregroundColor(DS.textPrimary)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(rule.streakCount)d")
                                .font(DS.Font.mono)
                                .foregroundColor(DS.textPrimary)
                        }
                    }
                    .card()
                }
            }
        }
    }
}

// MARK: - Dashboard rule row

struct DashboardRuleRow: View {
    let rule:     Rule
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: DS.Space.sm) {
            Circle()
                .fill(rule.isEnabled ? DS.accent : DS.textTertiary)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(rule.name)
                    .font(DS.Font.body)
                    .foregroundColor(rule.isEnabled ? DS.textPrimary : DS.textSecondary)
                Text(rule.triggerType.displaySummary)
                    .font(DS.Font.caption)
                    .foregroundColor(DS.textSecondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(SwitchToggleStyle(tint: DS.accent))
            .labelsHidden()
        }
        .card()
    }
}
