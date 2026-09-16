import SwiftUI

struct SettingsView: View {
    @StateObject private var store = StoreService.shared
    @StateObject private var byo = BYOKeyManager.shared
    @State private var falKeyInput = ""
    @State private var deepSeekKeyInput = ""
    @State private var showPaywall = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        Form {
            accountSection
            apiSection
            legalSection
            aboutSection
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var accountSection: some View {
        Section("Account") {
            if store.isPro {
                Label(store.isStudio ? "Studio plan active" : "Pro plan active", systemImage: "crown.fill")
                    .foregroundStyle(DesignSystem.amber)
            } else {
                Button {
                    showPaywall = true
                } label: {
                    Label("Upgrade to Pro", systemImage: "crown")
                        .foregroundStyle(DesignSystem.amber)
                }
            }
            Button {
                Task { await store.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        }
    }

    private var apiSection: some View {
        Section {
            SecureField("fal.ai API key", text: $falKeyInput)
            if byo.hasFalKey {
                Label("fal.ai key saved to Keychain", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
            SecureField("DeepSeek API key", text: $deepSeekKeyInput)
            if byo.hasDeepSeekKey {
                Label("DeepSeek key saved to Keychain", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            }
            Button("Save Keys") {
                if !falKeyInput.isEmpty {
                    byo.saveFalKey(falKeyInput)
                    falKeyInput = ""
                }
                if !deepSeekKeyInput.isEmpty {
                    byo.saveDeepSeekKey(deepSeekKeyInput)
                    deepSeekKeyInput = ""
                }
            }
            .disabled(falKeyInput.isEmpty && deepSeekKeyInput.isEmpty)
            if byo.hasFalKey || byo.hasDeepSeekKey {
                Button("Remove Saved Keys", role: .destructive) {
                    byo.deleteAll()
                }
            }
        } header: {
            Text("Advanced: Configure Custom API")
        } footer: {
            Text("Add your own API key for unlimited HD rendering and furniture identification. Keys are stored in your device Keychain only and never leave your device except to call the provider directly. Your renders are unlimited with your own key.")
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Link(destination: URL(string: "https://asunnyboy861.github.io/Sketcho/support.html")!) {
                Label("Support", systemImage: "questionmark.circle")
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/Sketcho/privacy.html")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            Link(destination: URL(string: "https://asunnyboy861.github.io/Sketcho/terms.html")!) {
                Label("Terms of Use", systemImage: "doc.text")
            }
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }
        }
    }

    private var aboutSection: some View {
        Section {
            Text(appVersion)
                .font(.footnote)
                .foregroundStyle(.secondary)
        } footer: {
            Text("You own your uploads and renders. Sketcho never uses your content for model training.")
        }
    }
}
