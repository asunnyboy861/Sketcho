import SwiftUI
import PencilKit

struct TapToEditView: View {
    let baseImage: UIImage
    @ObservedObject var session: RenderSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var canvas = PKCanvasView()
    @State private var instruction = ""
    @State private var isEditing = false
    @State private var editedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                if let edited = editedImage {
                    Image(uiImage: edited)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 380)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    ZStack {
                        Image(uiImage: baseImage)
                            .resizable()
                            .scaledToFit()
                        CanvasOverlay(canvas: canvas)
                            .opacity(0.6)
                    }
                    .frame(maxHeight: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Text("Circle the area to change, then describe the edit. Everything else stays identical.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("e.g. make the sofa black leather", text: $instruction)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await applyEdit() }
                } label: {
                    HStack {
                        if isEditing { ProgressView().tint(.black) }
                        Text("Apply Edit")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.amber)
                .disabled(instruction.isEmpty || isEditing)
                .accessibilityLabel("Apply edit to selected area")

                Spacer()
            }
            .padding()
            .background(DesignSystem.charcoal.ignoresSafeArea())
            .navigationTitle("Tap to Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .disabled(editedImage == nil)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func applyEdit() async {
        isEditing = true
        defer { isEditing = false }
        let strokes = canvas.drawing.strokes
        let mask = MaskBuilder.mask(from: strokes, size: baseImage.size)

        if let mask {
            let result = await AIRouter.shared.inpaint(
                base: baseImage, mask: mask,
                instruction: instruction,
                prompt: StructuredPrompt(positive: "", negative: "", style: session.selectedStyle.rawValue,
                                          lockStrength: session.lockStrength)
            )
            editedImage = result
        } else {
            editedImage = baseImage
        }
    }
}

struct CanvasOverlay: UIViewRepresentable {
    let canvas: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.tool = PKInkingTool(.pen, color: .systemOrange.withAlphaComponent(0.8), width: 12)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

enum MaskBuilder {
    static func mask(from strokes: [PKStroke], size: CGSize) -> CGImage? {
        guard !strokes.isEmpty, size.width > 0, size.height > 0 else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size)
        let maskImage = renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor.white.setFill()
            for stroke in strokes {
                let path = UIBezierPath()
                let points = stroke.path
                guard !points.isEmpty else { continue }
                let first = points.interpolatedPoints(by: .distance(8)).map { $0.location }
                guard let start = first.first else { continue }
                path.move(to: start)
                for point in first.dropFirst() {
                    path.addLine(to: point)
                }
                path.close()
                path.lineWidth = 36
                path.stroke(with: .normal, alpha: 1)
            }
        }
        return maskImage.cgImage
    }
}
