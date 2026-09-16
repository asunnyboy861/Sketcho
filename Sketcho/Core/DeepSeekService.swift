import Foundation
import UIKit

struct FurnitureItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var style: String
    var color: String
    var material: String
    var approxPriceUSD: Double

    enum CodingKeys: String, CodingKey {
        case id, name, style, color, material
        case approxPriceUSD = "approx_price_usd"
    }

    var searchURL: URL? {
        var components = URLComponents(string: "https://www.amazon.com/s")
        components?.queryItems = [URLQueryItem(name: "k", value: "\(name) \(color) \(material)")]
        return components?.url
    }
}

enum DeepSeekService {
    struct ServiceError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    static func identifyFurniture(image: UIImage) async throws -> [FurnitureItem] {
        guard let key = BYOKeyManager.shared.deepSeekKey else {
            throw ServiceError(message: "Add your DeepSeek API key in Settings to identify furniture.")
        }
        guard let jpeg = image.jpegData(compressionQuality: 0.6) else {
            throw ServiceError(message: "Could not read the image.")
        }
        let base64 = jpeg.base64EncodedString()
        let body: [String: Any] = [
            "model": "deepseek-vl",
            "messages": [[
                "role": "user",
                "content": [[
                    "type": "image_url",
                    "image_url": ["url": "data:image/jpeg;base64,\(base64)"]
                ], [
                    "type": "text",
                    "text": "List each furniture piece visible in this interior render as JSON: {\"items\": [{\"name\", \"style\", \"color\", \"material\", \"approx_price_usd\"}]}. Return only JSON."
                ]]
            ]],
            "response_format": ["type": "json_object"]
        ]
        var request = URLRequest(url: URL(string: "https://api.deepseek.com/chat/completions")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ServiceError(message: "DeepSeek service unavailable. Check your key and try again.")
        }
        let decoded = try JSONDecoder().decode(DeepSeekResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw ServiceError(message: "No furniture found.")
        }
        return parseFurniture(content: content)
    }

    static func parseFurniture(content: String) -> [FurnitureItem] {
        struct Wrapper: Codable {
            let items: [FurnitureItem]?
        }
        if let wrapper = try? JSONDecoder().decode(Wrapper.self, from: Data(content.utf8)),
           let items = wrapper.items {
            return items
        }
        if let items = try? JSONDecoder().decode([FurnitureItem].self, from: Data(content.utf8)) {
            return items
        }
        return []
    }
}

private struct DeepSeekResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
