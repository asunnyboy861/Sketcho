import Foundation
import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

enum PromptEngine {
    static let templateVersion = "v1.2"

    private static let styleDescriptors: [StylePack: String] = [
        .modern: "modern minimalist interior, clean lines, neutral palette, glass and steel accents, natural daylight",
        .scandinavian: "scandinavian interior, light oak wood, white walls, cozy textiles, soft diffused daylight",
        .industrial: "industrial loft interior, exposed brick, black steel frames, polished concrete floor, moody light",
        .japandi: "japandi interior, warm minimalism, low wooden furniture, paper lanterns, serene muted tones",
        .farmhouse: "modern farmhouse interior, shiplap walls, rustic wood beams, warm ambient lighting",
        .midcentury: "mid-century modern interior, walnut furniture, tapered legs, retro accents, warm sunlight"
    ]

    private static let negativeBase = "distorted geometry, warped windows, blurry, lowres, watermark, text, oversaturated, deformed furniture"

    private static let materialLexicon = [
        "walnut", "oak", "brass", "travertine", "terrazzo", "linen", "boucle",
        "leather", "marble", "concrete", "shiplap", "zellige tile", "brushed steel"
    ]

    static func roomTypeGuess(hasFurniture: Bool, dominantWarmth: Double) -> String {
        if hasFurniture { return dominantWarmth > 0.5 ? "cozy living room" : "modern living room" }
        return "empty interior space"
    }

    static func structuredPrompt(userInput: String, style: StylePack, lockStrength: Double,
                                 visionFacts: VisionFacts?) -> StructuredPrompt {
        let descriptor = styleDescriptors[style] ?? styleDescriptors[.modern]!
        let facts = visionFacts.map { facts -> String in
            let room = roomTypeGuess(hasFurniture: facts.hasFurniture, dominantWarmth: facts.warmth)
            return "\(room), preserved spatial layout"
        } ?? "interior space"
        var positive = "\(facts), \(descriptor)"
        if !userInput.isEmpty {
            positive += ", \(userInput.lowercased())"
        }
        positive += ", architectural photography, photorealistic, 8k detail, physically based materials, realistic lighting"
        positive += ", materials: \(materialLexicon.shuffled().prefix(3).joined(separator: ", "))"
        let negative = lockStrength >= 0.8
            ? negativeBase + ", altered layout, moved walls, invented windows"
            : negativeBase
        return StructuredPrompt(
            positive: positive,
            negative: negative,
            style: style.rawValue,
            lockStrength: lockStrength
        )
    }

    static func refineWithAFM(sessionInstructions: String, base: StructuredPrompt) async -> StructuredPrompt? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(instructions: sessionInstructions)
                let refined = try await session.respond(to: """
                    Improve this architecture rendering prompt. Keep layout words. Return only the improved prompt.
                    \(base.positive)
                    """)
                let text = refined.content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard text.count > 20 else { return nil }
                var result = base
                result.positive = text
                return result
            } catch {
                return nil
            }
        }
        #endif
        return nil
    }
}

struct VisionFacts {
    var hasFurniture: Bool
    var warmth: Double
    var dominantColors: [UIColor]
}
