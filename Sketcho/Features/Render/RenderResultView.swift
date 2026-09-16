import SwiftUI
import SwiftData

struct RenderResultView: View {
    @ObservedObject var session: RenderSessionViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var revealed = false
    @State private var showExport = false
    @State private var showTapToEdit = false
    @State private var showStyleQuad = false
    @State private var showShop = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let result = session.currentResult {
                    if let original = session.sourceImage {
                        CompareSlider(before: original, after: result)
                            .frame(height: 320)
                            .opacity(revealed ? 1 : 0)
                            .blur(radius: revealed ? 0 : 14)
                    } else {
                        Image(uiImage: result)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .opacity(revealed ? 1 : 0)
                            .blur(radius: revealed ? 0 : 14)
                    }

                    HStack {
                        Label(session.lastChannel.label, systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(DesignSystem.amber)
                            .padding(8)
                            .background(DesignSystem.amber.opacity(0.12), in: Capsule())
                        if session.lastPrompt != nil {
                            Text("\(Int(session.lockStrength * 100))% lock")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    actionGrid
                } else {
                    ContentUnavailableView(
                        "No render yet",
                        systemImage: "photo",
                        description: Text("Go back and render a preview or HD image first.")
                    )
                }
            }
            .padding()
        }
        .background(DesignSystem.charcoal.ignoresSafeArea())
        .navigationTitle("Result")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ChatView(session: session)
                } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
                .accessibilityLabel("Iterate with chat")
            }
        }
        .sheet(isPresented: $showExport) {
            if let result = session.currentResult {
                ExportView(image: result, original: session.sourceImage,
                           style: session.selectedStyle, lockStrength: session.lockStrength,
                           channel: session.lastChannel)
            }
        }
        .sheet(isPresented: $showTapToEdit) {
            if let result = session.currentResult {
                TapToEditView(baseImage: result, session: session)
            }
        }
        .sheet(isPresented: $showStyleQuad) {
            if let result = session.currentResult {
                StyleQuadView(baseImage: result, lockStrength: session.lockStrength)
            }
        }
        .sheet(isPresented: $showShop) {
            if let result = session.currentResult {
                ShopTheLookView(image: result)
            }
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .alert("Cloud rendering uploads your image",
               isPresented: $session.showUploadConsent) {
            Button("Continue") { session.confirmConsent(context: modelContext) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("HD rendering processes your image on a secure cloud service. Images are never used for training. You can turn this off anytime.")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { revealed = true }
        }
    }

    private var actionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            actionButton("Export", icon: "square.and.arrow.up") { showExport = true }
            actionButton("Tap to Edit", icon: "hand.tap.fill") { showTapToEdit = true }
            actionButton("Style Quad", icon: "square.grid.2x2.fill") { showStyleQuad = true }
            actionButton("Shop the Look", icon: "bag.fill") { showShop = true }
        }
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(DesignSystem.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
