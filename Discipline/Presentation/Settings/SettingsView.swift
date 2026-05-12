import SwiftUI

struct SettingsView: View {
    @StateObject private var vm        = SettingsViewModel()
    @State private var showExport      = false
    @State private var exportPayload   = ""
    @State private var showImport      = false
    @State private var importText      = ""
    @State private var importError     = false

    var body: some View {
        NavigationStack {
            Form {
                notificationsSection
                screenTimeSection
                backupSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Settings")
        }
        // Export sheet: share plain text JSON
        .sheet(isPresented: $showExport) {
            ShareSheet(items: [exportPayload])
        }
        // Import sheet: paste JSON
        .sheet(isPresented: $showImport) {
            importSheet
        }
    }

    // MARK: - Sections

    private var notificationsSection: some View {
        Section("Notifications") {
            HStack {
                Image(systemName: "bell.fill").foregroundColor(DS.accent)
                Text("Permission").foregroundColor(DS.textPrimary)
                Spacer()
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString)
                    else { return }
                    UIApplication.shared.open(url)
                }
                .font(DS.Font.caption)
                .foregroundColor(DS.accent)
            }

            Stepper(
                "Cooldown: \(vm.cooldownMinutes) min between alerts",
                value: $vm.cooldownMinutes, in: 1...120
            )
            .foregroundColor(DS.textPrimary)
            .onChange(of: vm.cooldownMinutes) { _ in vm.saveCooldown() }
        }
        .listRowBackground(DS.surface)
    }

    private var screenTimeSection: some View {
        Section("App Monitoring (Screen Time)") {
            HStack(alignment: .top, spacing: DS.Space.sm) {
                Image(systemName: "hourglass").foregroundColor(DS.warning)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Requires FamilyControls Entitlement")
                        .font(DS.Font.headline)
                        .foregroundColor(DS.textPrimary)
                    Text(
                        "App-launch and duration-based rules require Apple\'s FamilyControls " +
                        "entitlement, which requires a paid Apple Developer account and Apple\'s " +
                        "explicit approval. Once provisioned, these rule types will activate " +
                        "automatically. Time-based and conflict-based rules work right now."
                    )
                    .font(DS.Font.caption)
                    .foregroundColor(DS.textSecondary)
                }
            }
        }
        .listRowBackground(DS.surface)
    }

    private var backupSection: some View {
        Section("Backup & Restore") {
            Button {
                exportPayload = vm.exportRulesJSON() ?? "{}"
                showExport    = true
            } label: {
                Label("Export Rules as JSON", systemImage: "square.and.arrow.up")
                    .foregroundColor(DS.accent)
            }

            Button {
                showImport = true
                importText = ""
            } label: {
                Label("Import Rules from JSON", systemImage: "square.and.arrow.down")
                    .foregroundColor(DS.accent)
            }

            Button {
                exportPayload = vm.exportTemplatesJSON() ?? "{}"
                showExport    = true
            } label: {
                Label("Export Messages as JSON", systemImage: "square.and.arrow.up")
                    .foregroundColor(DS.accent)
            }
        }
        .listRowBackground(DS.surface)
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Discipline").foregroundColor(DS.textPrimary)
                Spacer()
                Text("1.0").foregroundColor(DS.textSecondary)
            }
            Text("All data is stored on-device. No accounts, no cloud, no tracking.")
                .font(DS.Font.caption)
                .foregroundColor(DS.textSecondary)
            Text("Built on FocusMe by Rodrigo Porto (MIT).")
                .font(DS.Font.caption)
                .foregroundColor(DS.textTertiary)
        }
        .listRowBackground(DS.surface)
    }

    // MARK: - Import sheet

    private var importSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DS.Space.md) {
                Text("Paste exported JSON below:")
                    .font(DS.Font.headline)
                    .foregroundColor(DS.textPrimary)

                TextEditor(text: $importText)
                    .font(DS.Font.mono)
                    .foregroundColor(DS.textPrimary)
                    .background(DS.surface)
                    .cornerRadius(DS.Radius.md)
                    .frame(maxHeight: .infinity)

                if importError {
                    Text("Invalid JSON — could not parse rules.")
                        .font(DS.Font.caption)
                        .foregroundColor(DS.danger)
                }
            }
            .padding(DS.Space.md)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Import Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showImport = false }
                        .foregroundColor(DS.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import") {
                        importError = false
                        guard !importText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        else { return }
                        // Validate: attempt decode before calling VM
                        guard
                            let data  = importText.data(using: .utf8),
                            let _     = try? JSONDecoder().decode([Rule].self, from: data)
                        else { importError = true; return }
                        vm.importRulesJSON(importText)
                        showImport = false
                    }
                    .foregroundColor(DS.accent)
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Share sheet wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
