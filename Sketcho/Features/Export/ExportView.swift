import SwiftUI
import UIKit
import AVFoundation

struct ExportView: View {
    let image: UIImage
    let original: UIImage?
    let style: StylePack
    let lockStrength: Double
    let channel: RenderChannel

    @Environment(\.dismiss) private var dismiss
    @State private var conceptBadge = true
    @State private var shareItem: Any?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .listRowBackground(Color.clear)
                }

                Section("Export Options") {
                    exportRow("4K PNG", subtitle: "Ultra resolution, watermark-free for Pro", icon: "photo.badge.arrow.up") {
                        shareItem = image.sketcho4K(conceptBadge: conceptBadge)
                    }
                    exportRow("Style Comparison", subtitle: "Before/after long image for sharing", icon: "rectangle.split.2x1") {
                        if let original {
                            shareItem = ComparisonComposer.compose(before: original, after: image)
                        }
                    }
                    exportRow("Concept Sketch PDF", subtitle: "Fidelity statement + license page", icon: "doc.richtext") {
                        shareItem = PDFComposer.conceptPDF(
                            image: image,
                            style: style,
                            lock: lockStrength,
                            channel: channel
                        )
                    }
                }

                Section {
                    Toggle(isOn: $conceptBadge) {
                        Label("Add \"Concept Sketch\" badge", systemImage: "checkmark.seal")
                    }
                } footer: {
                    Text("The badge marks the render as a concept, per professional disclosure practice. Commercial license is included with Pro and Studio plans.")
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: .init(get: { shareItem != nil }, set: { if !$0 { shareItem = nil } })) {
                if let shareItem {
                    ShareSheet(items: [shareItem])
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func exportRow(_ title: String, subtitle: String, icon: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(DesignSystem.amber)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

extension UIImage {
    func sketcho4K(conceptBadge: Bool) -> UIImage {
        let target: CGFloat = 4096
        let scale = min(target / size.width, target / size.height, 4)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { ctx in
            draw(in: CGRect(origin: .zero, size: newSize))
            if conceptBadge {
                let text = "Concept Sketch · Sketcho"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 28, weight: .semibold),
                    .foregroundColor: UIColor.white
                ]
                let textSize = (text as NSString).size(withAttributes: attributes)
                let pad: CGFloat = 14
                let rect = CGRect(x: 16, y: newSize.height - textSize.height - pad * 2 - 16,
                                  width: textSize.width + pad * 2, height: textSize.height + pad * 2)
                UIColor.black.withAlphaComponent(0.55).setFill()
                UIBezierPath(roundedRect: rect, cornerRadius: 10).fill()
                (text as NSString).draw(at: CGPoint(x: rect.minX + pad, y: rect.minY + pad),
                                        withAttributes: attributes)
            }
        }
    }
}

enum ComparisonComposer {
    static func compose(before: UIImage, after: UIImage) -> UIImage {
        let width: CGFloat = 1080
        let height: CGFloat = 1440
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
            let cell = CGRect(x: 0, y: 40, width: width, height: height - 200)
            let halfLeft = CGRect(x: cell.minX, y: cell.minY, width: cell.width / 2, height: cell.height)
            let halfRight = CGRect(x: cell.midX, y: cell.minY, width: cell.width / 2, height: cell.height)
            let leftFit = AVMakeRect(aspectRatio: before.size, insideRect: halfLeft)
            let rightFit = AVMakeRect(aspectRatio: after.size, insideRect: halfRight)
            before.draw(in: leftFit)
            after.draw(in: rightFit)
            drawLabel("Before", at: CGPoint(x: 24, y: 8))
            drawLabel("After", at: CGPoint(x: width - 160, y: 8))
            drawLabel("Made with Sketcho", at: CGPoint(x: 24, y: height - 90))
        }
    }

    private static func drawLabel(_ text: String, at point: CGPoint) {
        (text as NSString).draw(at: point, withAttributes: [
            .font: UIFont.boldSystemFont(ofSize: 36),
            .foregroundColor: UIColor.white
        ])
    }
}

enum PDFComposer {
    static func conceptPDF(image: UIImage, style: StylePack, lock: Double,
                           channel: RenderChannel) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { ctx in
            ctx.beginPage()
            let title = "Concept Sketch — Sketcho"
            (title as NSString).draw(at: CGPoint(x: 40, y: 36), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 22)
            ])

            let imageRect = CGRect(x: 40, y: 70, width: pageRect.width - 80, height: 400)
            let fitted = AVMakeRect(aspectRatio: image.size, insideRect: imageRect)
            image.draw(in: fitted)

            let lines = [
                "Style: \(style.displayName)",
                "Geometry lock: \(Int(lock * 100))%",
                "Render channel: \(channel.label)",
                "Generated: \(Date().formatted())",
                "",
                "Geometry fidelity statement",
                "This render preserves the spatial layout of the original input to the extent of the",
                "geometry lock stated above. It is a concept visualization, not a construction document.",
                "",
                "Commercial license",
                "The purchaser holds full rights to this visualization for client presentations and",
                "marketing. Sketcho claims no ownership of user uploads or generated outputs, and",
                "never uses user content for model training."
            ]
            var y = fitted.maxY + 30
            for line in lines {
                let bold = line == "Geometry fidelity statement" || line == "Commercial license"
                (line as NSString).draw(at: CGPoint(x: 40, y: y), withAttributes: [
                    .font: bold ? UIFont.boldSystemFont(ofSize: 13) : UIFont.systemFont(ofSize: 11)
                ])
                y += bold ? 24 : 17
            }
        }
    }
}
