import SwiftUI

struct ShopTheLookView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    @State private var items: [FurnitureItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty && !isLoading {
                    emptyState
                } else {
                    List(items) { item in
                        Link(destination: item.searchURL ?? URL(string: "https://www.amazon.com")!) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("\(item.style) · \(item.color) · \(item.material)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if item.approxPriceUSD > 0 {
                                    Text("$\(Int(item.approxPriceUSD))")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(DesignSystem.amber)
                                }
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Shop the Look")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await identify()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No furniture identified yet", systemImage: "bag")
        } description: {
            Text(errorMessage ?? "Furniture identification uses your own DeepSeek API key. Add one in Settings to match real products in this render.")
        } actions: {
            if errorMessage?.contains("DeepSeek") == true || errorMessage == nil {
                Button("Open Settings") {
                    dismiss()
                }
            }
        }
    }

    private func identify() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await DeepSeekService.identifyFurniture(image: image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
