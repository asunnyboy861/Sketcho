import Combine
import Foundation
import UIKit

@MainActor
final class AIRouter: ObservableObject {
    static let shared = AIRouter()

    @Published var lastChannel: RenderChannel = .onDevice

    func resolve(quality: RenderQuality, entitlements: Entitlements) -> RenderChannel {
        if quality == .hd {
            if entitlements.hasBYOKey { return .byoCloud }
            if StoreService.shared.isPro {
                return entitlements.hasBYOKey ? .byoCloud : .cloud
            }
            if QuotaService.shared.canUseFreeHD() { return .cloud }
            return .onDeviceEnhanced
        }
        return .onDevice
    }

    func render(image: UIImage, prompt: StructuredPrompt, conditions: ConditionMaps?,
                quality: RenderQuality) async -> (image: UIImage, channel: RenderChannel) {
        let entitlements = Entitlements(hasBYOKey: BYOKeyManager.shared.hasFalKey)
        let channel = resolve(quality: quality, entitlements: entitlements)
        lastChannel = channel

        switch channel {
        case .byoCloud, .cloud:
            do {
                let hd = try await CloudRenderer.renderHD(
                    prompt: prompt,
                    edge: conditions?.edge,
                    depth: conditions?.depth,
                    useBYO: channel == .byoCloud
                )
                if channel == .cloud { QuotaService.shared.consumeHD() }
                return (hd, channel)
            } catch {
                let fallback = OnDeviceRenderer.render(
                    image: image, prompt: prompt, conditions: conditions, enhanced: true
                )
                return (fallback, .onDeviceEnhanced)
            }
        case .onDeviceEnhanced:
            return (OnDeviceRenderer.render(image: image, prompt: prompt,
                                            conditions: conditions, enhanced: true), channel)
        case .onDevice:
            return (OnDeviceRenderer.render(image: image, prompt: prompt,
                                            conditions: conditions, enhanced: false), channel)
        }
    }

    func inpaint(base: UIImage, mask: CGImage, instruction: String,
                 prompt: StructuredPrompt) async -> UIImage {
        if BYOKeyManager.shared.hasFalKey || StoreService.shared.isPro {
            do {
                return try await CloudRenderer.inpaint(
                    image: base, mask: mask,
                    prompt: "edit only masked area: \(instruction); keep everything else identical, \(prompt.positive)",
                    useBYO: BYOKeyManager.shared.hasFalKey
                )
            } catch {
                return OnDeviceRenderer.inpaintLocal(base: base, mask: mask, instruction: instruction)
            }
        }
        return OnDeviceRenderer.inpaintLocal(base: base, mask: mask, instruction: instruction)
    }

    func buildPrompt(userInput: String, style: StylePack, lockStrength: Double,
                     visionFacts: VisionFacts?) async -> StructuredPrompt {
        let base = PromptEngine.structuredPrompt(
            userInput: userInput, style: style, lockStrength: lockStrength,
            visionFacts: visionFacts
        )
        return await PromptEngine.refineWithAFM(
            sessionInstructions: "You are an expert architectural visualization prompt engineer. Use precise material, lighting, and lens vocabulary.",
            base: base
        ) ?? base
    }
}

struct Entitlements {
    var hasBYOKey: Bool
}

@MainActor
final class BYOKeyManager: ObservableObject {
    static let shared = BYOKeyManager()

    static let falService = "com.zzoutuo.Sketcho.keys"
    static let falAccount = "fal.api"
    static let deepseekAccount = "deepseek.api"
    static let replicateAccount = "replicate.api"

    @Published var hasFalKey: Bool = false
    @Published var hasDeepSeekKey: Bool = false

    private init() {
        refresh()
    }

    func refresh() {
        hasFalKey = falKey != nil
        hasDeepSeekKey = deepSeekKey != nil
    }

    var falKey: String? {
        KeychainHelper.readString(service: Self.falService, account: Self.falAccount)
    }

    var deepSeekKey: String? {
        KeychainHelper.readString(service: Self.falService, account: Self.deepseekAccount)
    }

    func saveFalKey(_ key: String) {
        KeychainHelper.saveString(key, service: Self.falService, account: Self.falAccount)
        refresh()
    }

    func saveDeepSeekKey(_ key: String) {
        KeychainHelper.saveString(key, service: Self.falService, account: Self.deepseekAccount)
        refresh()
    }

    func deleteAll() {
        KeychainHelper.delete(service: Self.falService, account: Self.falAccount)
        KeychainHelper.delete(service: Self.falService, account: Self.deepseekAccount)
        refresh()
    }
}
