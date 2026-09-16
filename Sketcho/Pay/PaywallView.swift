import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = StoreService.shared
    @State private var purchasingId: String?
    @State private var successMessage: String?

    private let privacyURL = URL(string: "https://asunnyboy861.github.io/Sketcho/privacy.html")!
    private let termsURL = URL(string: "https://asunnyboy861.github.io/Sketcho/terms.html")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header

                    if store.isLoading {
                        ProgressView()
                    } else if store.products.isEmpty {
                        VStack(spacing: 8) {
                            Text(store.loadError ?? "Purchase options are unavailable right now.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Try Again") {
                                Task { await store.loadProducts() }
                            }
                        }
                    } else {
                        ForEach(store.products, id: \.id) { product in
                            productRow(product)
                        }
                    }

                    VStack(spacing: 6) {
                        Link("Privacy Policy", destination: privacyURL)
                        Link("Terms of Use", destination: termsURL)
                    }
                    .font(.caption2)
                    .tint(DesignSystem.amber)
                    .padding(.top, 4)

                    Text("Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. Cancel anytime in Settings — one tap. The lifetime purchase is one-time and never renews.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Restore Purchases") {
                        Task { await store.restorePurchases() }
                    }
                    .font(.subheadline)

                    if let success = successMessage {
                        Text(success)
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    if let error = store.loadError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .background(DesignSystem.charcoal.ignoresSafeArea())
            .navigationTitle("Sketcho Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(DesignSystem.amber)
            Text("Unlock Premium Features")
                .font(.title2.bold())
            Text("4K export · Tap to Edit · Style Quad · full Lock Mode · commercial license")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private func productRow(_ product: Product) -> some View {
        Button {
            Task {
                purchasingId = product.id
                let ok = await store.purchase(product)
                purchasingId = nil
                if ok { successMessage = "Thank you! Premium features are unlocked." }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle(for: product))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if purchasingId == product.id {
                    ProgressView()
                } else {
                    Text(product.displayPrice)
                        .font(.headline)
                        .foregroundStyle(DesignSystem.amber)
                }
            }
            .padding(14)
            .background(DesignSystem.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(product.displayName), \(product.displayPrice)")
    }

    private func subtitle(for product: Product) -> String {
        switch product.id {
        case StoreService.proMonthly: return "All Pro features, billed monthly"
        case StoreService.proYearly: return "All Pro features, billed yearly — save 49%"
        case StoreService.proLifetime: return "Pay once, forever. Includes unlimited BYO-key renders"
        case StoreService.studioMonthly: return "Pro + batch 16, priority queue, client demo, white-label"
        case StoreService.studioYearly: return "All Studio features, billed yearly — save 45%"
        default: return ""
        }
    }
}
