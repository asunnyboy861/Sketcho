import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
            ProTabView()
                .tabItem {
                    Label("Pro", systemImage: "crown")
                }
        }
        .tint(DesignSystem.amber)
    }
}

struct ProTabView: View {
    @StateObject private var store = StoreService.shared

    var body: some View {
        NavigationStack {
            if store.isPro {
                SettingsView()
            } else {
                PaywallMarketingView()
            }
        }
    }
}

private struct PaywallMarketingView: View {
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundStyle(DesignSystem.amber)
            Text("Sketcho Pro")
                .font(.largeTitle.bold())
            VStack(alignment: .leading, spacing: 12) {
                feature("4K export, watermark-free")
                feature("Tap to Edit — change anything, keep the rest")
                feature("Style Quad — one image, four styles")
                feature("Full Lock Mode with fidelity badge")
                feature("Commercial license + Concept Sketch PDF")
                feature("Unlimited renders with your own API key")
            }
            Button {
                showPaywall = true
            } label: {
                Text("See Plans")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignSystem.amber)
            Spacer()
        }
        .padding()
        .frame(maxWidth: 720)
        .background(DesignSystem.charcoal.ignoresSafeArea())
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private func feature(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .foregroundStyle(.primary)
    }
}
