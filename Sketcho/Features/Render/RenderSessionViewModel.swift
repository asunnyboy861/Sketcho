import Combine
import SwiftUI
import SwiftData

@MainActor
final class RenderSessionViewModel: ObservableObject {
    @Published var sourceImage: UIImage?
    @Published var selectedStyle: StylePack = .modern
    @Published var lockStrength: Double = 0.8
    @Published var lockModeOn: Bool = true
    @Published var instruction: String = ""
    @Published var isRendering: Bool = false
    @Published var currentResult: UIImage?
    @Published var lastChannel: RenderChannel = .onDevice
    @Published var lastPrompt: StructuredPrompt?
    @Published var errorMessage: String?
    @Published var showCamera: Bool = false
    @Published var showUploadConsent: Bool = false

    private var pendingConsentQuality: RenderQuality?

    private var conditions: ConditionMaps?
    private var facts: VisionFacts?

    var canRender: Bool { sourceImage != nil && !isRendering }

    var quotaLabel: String {
        QuotaService.shared.refresh()
        let remaining = QuotaService.shared.hdRemainingToday
        return remaining > 0 ? "\(remaining) free HD render\(remaining == 1 ? "" : "s") today · unlimited previews" : "Unlimited previews · HD refreshes tomorrow"
    }

    func load(image: UIImage) {
        sourceImage = image
        currentResult = nil
        facts = VisionPreprocessor.visionFacts(for: image)
        conditions = VisionPreprocessor.conditionMaps(for: image)
    }

    func requestRender(quality: RenderQuality, context: ModelContext) {
        if quality == .hd && !UserDefaults.standard.bool(forKey: "sketcho.uploadConsent")
            && (BYOKeyManager.shared.hasFalKey || StoreService.shared.isPro || QuotaService.shared.canUseFreeHD()) {
            pendingConsentQuality = quality
            showUploadConsent = true
            return
        }
        Task { await render(quality: quality, context: context, project: nil) }
    }

    func confirmConsent(context: ModelContext) {
        UserDefaults.standard.set(true, forKey: "sketcho.uploadConsent")
        if let quality = pendingConsentQuality {
            pendingConsentQuality = nil
            Task { await render(quality: quality, context: context, project: nil) }
        }
    }

    func render(quality: RenderQuality, context: ModelContext, project: Project?) async {
        guard let image = sourceImage else { return }
        isRendering = true
        errorMessage = nil
        defer { isRendering = false }

        let prompt = await AIRouter.shared.buildPrompt(
            userInput: instruction,
            style: selectedStyle,
            lockStrength: lockModeOn ? lockStrength : 0.4,
            visionFacts: facts
        )
        lastPrompt = prompt
        let (result, channel) = await AIRouter.shared.render(
            image: image,
            prompt: prompt,
            conditions: lockModeOn ? conditions : nil,
            quality: quality
        )
        currentResult = result
        lastChannel = channel
        if quality == .hd && channel == .onDeviceEnhanced {
            errorMessage = "Cloud HD was unavailable, so an enhanced on-device render was used."
        }
        QuotaService.shared.refresh()

        let version = RenderVersion(
            prompt: prompt.positive,
            style: selectedStyle,
            lockStrength: lockStrength,
            channel: channel,
            quality: quality,
            imageData: result.jpegData(compressionQuality: 0.9) ?? Data(),
            originalImageData: image.jpegData(compressionQuality: 0.9),
            edgeData: conditions?.edge.pngData,
            depthData: conditions?.depth?.pngData
        )
        let target = project ?? createProject(context)
        version.project = target
        target.updatedAt = Date()
        context.insert(version)
        try? context.save()
    }

    private func createProject(_ context: ModelContext) -> Project {
        let name = instruction.isEmpty
            ? "\(selectedStyle.displayName) · \(Date().formatted(date: .abbreviated, time: .shortened))"
            : String(instruction.prefix(40))
        let project = Project(name: name)
        context.insert(project)
        try? context.save()
        return project
    }
}

extension CGImage {
    var pngData: Data? {
        UIImage(cgImage: self).pngData()
    }
}
