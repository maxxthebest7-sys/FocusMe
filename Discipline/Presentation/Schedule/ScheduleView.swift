import SwiftUI

struct ScheduleView: View {
    @StateObject private var vm          = ScheduleViewModel()
    @State private var showAdd           = false
    @State private var editingBlock: ScheduleBlock? = nil

    var body: some View {
        NavigationStack {
            Group {
                if vm.schedule.blocks.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(vm.schedule.blocks) { block in
                            Button { editingBlock = block } label: {
                                ScheduleBlockRow(block: block)
                            }
                            .listRowBackground(DS.surface)
                            .listRowSeparatorTint(DS.surfaceBorder)
                        }
                        .onDelete { vm.deleteBlocks(at: $0) }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black.ignoresSafeArea())
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus").foregroundColor(DS.accent)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddEditScheduleBlockView(mode: .add) { vm.addBlock($0) }
            }
            .sheet(item: $editingBlock) { block in
                AddEditScheduleBlockView(mode: .edit(block)) { vm.updateBlock($0) }
            }
        }
        .onAppear { vm.onAppear() }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Space.lg) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 52))
                .foregroundColor(DS.textTertiary)
            Text("No schedule blocks.")
                .font(DS.Font.titleBold)
                .foregroundColor(DS.textPrimary)
            Text("Define your sleep, study, and workout windows so Discipline can detect conflicts.")
                .font(DS.Font.body)
                .foregroundColor(DS.textSecondary)
                .multilineTextAlignment(.center)
            Button("Add Block") { showAdd = true }
                .foregroundColor(DS.accent)
                .font(DS.Font.headline)
        }
        .padding(DS.Space.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Block row

struct ScheduleBlockRow: View {
    let block: ScheduleBlock

    var body: some View {
        HStack(spacing: DS.Space.md) {
            Image(systemName: block.type.sfSymbol)
                .foregroundColor(DS.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(block.label)
                    .font(DS.Font.headline)
                    .foregroundColor(DS.textPrimary)
                Text("\(block.startTimeString) – \(block.endTimeString)")
                    .font(DS.Font.caption)
                    .foregroundColor(DS.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(DS.textTertiary)
        }
        .padding(.vertical, 6)
    }
}
