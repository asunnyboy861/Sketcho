import UIKit

enum OnDeviceRenderer {
    static func render(image: UIImage, prompt: StructuredPrompt,
                       conditions: ConditionMaps?, enhanced: Bool) -> UIImage {
        let style = StylePack(rawValue: prompt.style) ?? .modern
        return VisionPreprocessor.stylizedRender(
            from: image, style: style,
            lockStrength: prompt.lockStrength,
            enhanced: enhanced
        )
    }

    static func inpaintLocal(base: UIImage, mask: CGImage, instruction: String) -> UIImage {
        guard let baseCG = base.cgImage else { return base }
        let width = baseCG.width
        let height = baseCG.height
        let size = CGSize(width: width, height: height)

        let tinted = UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.systemOrange.withAlphaComponent(0.9).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        let tintMask = UIGraphicsImageRenderer(size: size).image { _ in
            UIImage(cgImage: mask).draw(in: CGRect(origin: .zero, size: size))
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            UIImage(cgImage: baseCG).draw(in: CGRect(origin: .zero, size: size))
            tintMask.draw(in: CGRect(origin: .zero, size: size), blendMode: .overlay, alpha: 0.35)
            tintMask.draw(in: CGRect(origin: .zero, size: size), blendMode: .multiply, alpha: 0.6)
            tinted.draw(in: CGRect(origin: .zero, size: size), blendMode: .overlay, alpha: 0.25)
        }
    }
}
