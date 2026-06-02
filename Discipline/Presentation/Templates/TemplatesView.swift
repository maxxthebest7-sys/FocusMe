import SwiftUI

struct TemplatesView: View {
    @StateObject private var vm = TemplatesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.templates.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(vm.templates) { template in
                            NavigationLink {
                                AddEditTemplateView(mode: .edit(template)) { vm.update($0) }
                            } label: {
                                TemplateRow(template: template)
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
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { vm.showAddTemplate = true } label: {
                        Image(systemName: "plus").foregroundColor(DS.accent)
                    }
                }
            }
            .sheet(isPresented: $vm.showAddTemplate) {
                AddEditTemplateView(mode: .add) { vm.add($0) }
            }
        }
        .onAppear { vm.onAppear() }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Space.lg) {
            Image(systemName: "text.bubble")
                .font(.system(size: 52))
                .foregroundColor(DS.textTertiary)
            Text("No messages yet.")
                .font(DS.Font.titleBold)
                .foregroundColor(DS.textPrimary)
            Text("Write the words your future self needs to hear.")
                .font(DS.Font.body)
                .foregroundColor(DS.textSecondary)
                .multilineTextAlignment(.center)
            Text("Starter templates were loaded automatically. Tap + to add your own.")
                .font(DS.Font.caption)
                .foregroundColor(DS.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(DS.Space.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Template row

struct TemplateRow: View {
    let template: NotificationTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: DS.Space.sm) {
                Text(template.title)
                    .font(DS.Font.headline)
                    .foregroundColor(DS.textPrimary)

                if template.isGlobal {
                    Text("GLOBAL")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(DS.accent)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(DS.accentDim)
                        .cornerRadius(4)
                }

                Spacer()
            }

            Text(template.body)
                .font(DS.Font.caption)
                .foregroundColor(DS.textSecondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
