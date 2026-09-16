import Foundation
import SwiftData
import UIKit

enum RenderQuality: String, Codable {
    case preview
    case hd
}

enum RenderChannel: String, Codable {
    case onDevice
    case onDeviceEnhanced
    case cloud
    case byoCloud
}

enum StylePack: String, CaseIterable, Codable, Identifiable {
    case modern, scandinavian, industrial, japandi, farmhouse, midcentury

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .modern: return "Modern"
        case .scandinavian: return "Scandinavian"
        case .industrial: return "Industrial"
        case .japandi: return "Japandi"
        case .farmhouse: return "Farmhouse"
        case .midcentury: return "Mid-century"
        }
    }

    var symbol: String {
        switch self {
        case .modern: return "square.grid.2x2"
        case .scandinavian: return "leaf"
        case .industrial: return "gearshape.2"
        case .japandi: return "seal"
        case .farmhouse: return "house"
        case .midcentury: return "chair.lounge.fill"
        }
    }
}

@Model
final class Project {
    var name: String
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \RenderVersion.project)
    var versions: [RenderVersion] = []

    init(name: String, createdAt: Date = Date()) {
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }

    var latestVersion: RenderVersion? {
        versions.sorted { $0.createdAt < $1.createdAt }.last
    }
}

@Model
final class RenderVersion {
    var prompt: String
    var styleRaw: String
    var lockStrength: Double
    var channelRaw: String
    var qualityRaw: String
    var imageData: Data
    var originalImageData: Data?
    var edgeData: Data?
    var depthData: Data?
    var createdAt: Date
    var project: Project?

    init(prompt: String, style: StylePack, lockStrength: Double, channel: RenderChannel,
         quality: RenderQuality, imageData: Data, originalImageData: Data? = nil,
         edgeData: Data? = nil, depthData: Data? = nil, createdAt: Date = Date()) {
        self.prompt = prompt
        self.styleRaw = style.rawValue
        self.lockStrength = lockStrength
        self.channelRaw = channel.rawValue
        self.qualityRaw = quality.rawValue
        self.imageData = imageData
        self.originalImageData = originalImageData
        self.edgeData = edgeData
        self.depthData = depthData
        self.createdAt = createdAt
    }

    var style: StylePack { StylePack(rawValue: styleRaw) ?? .modern }
    var channel: RenderChannel { RenderChannel(rawValue: channelRaw) ?? .onDevice }
    var quality: RenderQuality { RenderQuality(rawValue: qualityRaw) ?? .preview }
    var image: UIImage? { UIImage(data: imageData) }
    var originalImage: UIImage? { originalImageData.flatMap(UIImage.init(data:)) }
}

struct StructuredPrompt: Codable, Equatable {
    var positive: String
    var negative: String
    var style: String
    var lockStrength: Double
}
