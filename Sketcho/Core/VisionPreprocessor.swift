import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

struct ConditionMaps {
    var edge: CGImage
    var depth: CGImage?
}

enum VisionPreprocessor {
    private static let context = CIContext(options: [.useSoftwareRenderer: false])

    static func conditionMaps(for image: UIImage) -> ConditionMaps {
        let edge = cannyEdges(from: image) ?? image.cgImage!
        let depth = depthMap(from: image)
        return ConditionMaps(edge: edge, depth: depth)
    }

    static func visionFacts(for image: UIImage) -> VisionFacts {
        guard let cgImage = image.cgImage else {
            return VisionFacts(hasFurniture: true, warmth: 0.5, dominantColors: [])
        }
        let filter = CIFilter.areaAverage()
        filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: CGRect(x: 0, y: 0, width: 1, height: 1)), forKey: kCIInputExtentKey)
        var warmth = 0.5
        if let output = filter.outputImage,
           let pixel = pixelRGB(output) {
            let r = CGFloat(pixel.0) / 255
            let b = CGFloat(pixel.2) / 255
            warmth = Double((r - b + 1) / 2)
        }
        return VisionFacts(hasFurniture: true, warmth: warmth, dominantColors: [])
    }

    private static func pixelRGB(_ image: CIImage) -> (UInt8, UInt8, UInt8)? {
        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(image,
                       toBitmap: &pixel,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        return (pixel[0], pixel[1], pixel[2])
    }

    static func cannyEdges(from image: UIImage) -> CGImage? {
        guard var ciImage = image.cgImage.map(CIImage.init) else { return nil }
        let scale = 1024.0 / max(ciImage.extent.width, ciImage.extent.height)
        if scale < 1 {
            let sized = CIFilter.lanczosScaleTransform()
            sized.inputImage = ciImage
            sized.scale = Float(scale)
            if let out = sized.outputImage { ciImage = out }
        }
        let mono = CIFilter.colorControls()
        mono.inputImage = ciImage
        mono.saturation = 0
        var current = mono.outputImage ?? ciImage

        let edges = CIFilter(name: "CIConvolutionEdgeDetect")
        edges?.setValue(current.clampedToExtent(), forKey: kCIInputImageKey)
        edges?.setValue(0, forKey: kCIInputBiasKey)
        if let out = edges?.outputImage { current = out }

        let threshold = CIFilter.colorControls()
        threshold.inputImage = current
        threshold.contrast = 2.5
        threshold.saturation = 0
        current = threshold.outputImage ?? current

        return context.createCGImage(current, from: current.extent) ?? image.cgImage
    }

    static func depthMap(from image: UIImage) -> CGImage? {
        guard var ciImage = image.cgImage.map(CIImage.init) else { return nil }
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = ciImage
        blur.radius = 24
        ciImage = blur.outputImage ?? ciImage
        let mono = CIFilter.colorControls()
        mono.inputImage = ciImage
        mono.saturation = 0
        let out = mono.outputImage ?? ciImage
        return context.createCGImage(out, from: out.extent)
    }

    static func stylizedRender(from image: UIImage, style: StylePack,
                               lockStrength: Double, enhanced: Bool) -> UIImage {
        guard var ciImage = image.cgImage.map(CIImage.init) else { return image }
        let workingSize: CGFloat = enhanced ? 2048 : 1024
        let scale = workingSize / max(ciImage.extent.width, ciImage.extent.height)
        let sized = CIFilter.lanczosScaleTransform()
        sized.inputImage = ciImage
        sized.scale = Float(scale)
        ciImage = sized.outputImage ?? ciImage

        let controls = CIFilter.colorControls()
        controls.inputImage = ciImage
        controls.saturation = style == .japandi ? 0.75 : 1.1
        controls.brightness = style == .industrial ? -0.02 : 0.02
        controls.contrast = enhanced ? 1.15 : 1.05
        ciImage = controls.outputImage ?? ciImage

        if let warm = CIFilter(name: "CITemperatureAndTint") {
            let target: (CGFloat, CGFloat) = style == .industrial ? (5500, 6500) : (7800, 3200)
            warm.setValue(ciImage, forKey: kCIInputImageKey)
            warm.setValue(CIVector(x: target.0, y: target.1), forKey: "inputNeutral")
            warm.setValue(CIVector(x: 6500, y: 3200), forKey: "inputTargetNeutral")
            ciImage = warm.outputImage ?? ciImage
        }

        if lockStrength >= 0.8, let edge = cannyEdges(from: image) {
            let edgeCI = CIImage(cgImage: edge).transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            let invert = CIFilter.colorInvert()
            invert.inputImage = edgeCI
            if let inverted = invert.outputImage {
                let soft = CIFilter.gaussianBlur()
                soft.inputImage = inverted
                soft.radius = 1.5
                let blended = CIFilter.multiplyBlendMode()
                blended.inputImage = ciImage
                blended.backgroundImage = soft.outputImage ?? inverted
                ciImage = blended.outputImage ?? ciImage
            }
        }

        if enhanced, let sharpened = CIFilter(name: "CISharpenLuminance") {
            sharpened.setValue(ciImage, forKey: kCIInputImageKey)
            sharpened.setValue(0.6, forKey: kCIInputSharpnessKey)
            ciImage = sharpened.outputImage ?? ciImage
        }

        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }

    private static func render(_ image: CIImage) -> (UInt8, UInt8, UInt8)? {
        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(image,
                       toBitmap: &pixel,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        return (pixel[0], pixel[1], pixel[2])
    }
}
