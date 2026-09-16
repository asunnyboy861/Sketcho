import SwiftUI

struct StyleQuadView: View {
    let baseImage: UIImage
    let lockStrength: Double
    @Environment(\.dismiss) private var dismiss

    @State private var styles: [StylePack] = [.modern, .scandinavian, .industrial, .japandi]
    @State private var results: [StylePack: UIImage] = [:]
    @State private var isRendering = false
    @State private var progress: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if isRendering {
                        ProgressView(value: progress)
                            .tint(DesignSystem.amber)
                        Text("Generating 4 styles… \(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(styles) { style in
                            quadCell(style)
                        }
                    }

                    if !results.isEmpty {
                        Button {
                            exportComparison()
                        } label: {
                            Label("Export Comparison", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignSystem.amber)
                        .accessibilityLabel("Export style comparison image")
                    }
                }
                .padding()
            }
            .background(DesignSystem.charcoal.ignoresSafeArea())
            .navigationTitle("Style Quad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(isRendering ? "Rendering…" : "Generate") {
                        Task { await generate() }
                    }
                    .disabled(isRendering)
                }
            }
            .sheet(isPresented: $showShare) {
                if let shared {
                    ShareSheet(items: [shared])
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @State private var showShare = false
    @State private var shared: UIImage?

    private func quadCell(_ style: StylePack) -> some View {
        VStack(spacing: 6) {
            ZStack {
                if let image = results[style] {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.cardBackground)
                        .frame(height: 130)
                        .overlay {
                            if isRendering {
                                ProgressView()
                            } else {
                                Image(systemName: style.symbol)
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
            }
            Text(style.displayName)
                .font(.caption.weight(.medium))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Style \(style.displayName)\(results[style] != nil ? ", rendered" : "")")
    }

    private func generate() async {
        isRendering = true
        progress = 0
        defer { isRendering = false }
        for (index, style) in styles.enumerated() {
            let prompt = PromptEngine.structuredPrompt(
                userInput: "", style: style, lockStrength: lockStrength, visionFacts: nil
            )
            let rendered = await AIRouter.shared.render(
                image: baseImage, prompt: prompt, conditions: nil, quality: .preview
            ).image
            results[style] = rendered
            progress = Double(index + 1) / Double(styles.count)
        }
    }

    private func exportComparison() {
        let cellW: CGFloat = 512
        let cellH: CGFloat = 384
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: cellW * 2, height: cellH * 2 + 120))
        let image = renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: cellW * 2, height: cellH * 2 + 120))
            let ordered = styles
            for (index, style) in ordered.enumerated() {
                let x = CGFloat(index % 2) * cellW
                let y = CGFloat(index / 2) * (cellH + 40)
                if let img = results[style] {
                    img.draw(in: CGRect(x: x, y: y + 30, width: cellW, height: cellH))
                }
                (style.displayName as NSString).draw(
                    at: CGPoint(x: x + 16, y: y + 4),
                    withAttributes: [
                        .font: UIFont.boldSystemFont(ofSize: 24),
                        .foregroundColor: UIColor.white
                    ]
                )
            }
            ("Made with Sketcho" as NSString).draw(
                at: CGPoint(x: 16, y: cellH * 2 + 60),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 20),
                    .foregroundColor: UIColor(white: 0.7, alpha: 1)
                ]
            )
        }
        shared = image
        showShare = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
