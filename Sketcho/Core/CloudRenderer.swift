import Foundation
import UIKit

enum CloudRenderer {
    struct CloudError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    static func renderHD(prompt: StructuredPrompt, edge: CGImage?, depth: CGImage?,
                         useBYO: Bool, timeout: TimeInterval = 30) async throws -> UIImage {
        guard let key = BYOKeyManager.shared.falKey else {
            throw CloudError(message: "Cloud rendering needs an API key. Add one in Settings, or use the free on-device preview.")
        }
        let endpoint = "https://fal.run/fal-ai/flux/dev"
        var payload: [String: Any] = [
            "prompt": prompt.positive,
            "negative_prompt": prompt.negative,
            "num_inference_steps": 28,
            "guidance_scale": 3.5,
            "output_format": "png"
        ]
        if let edge {
            payload["controlnets"] = [[
                "path": "https://fal.run/controlnets/canny",
                "image_url": dataURI(edge),
                "strength": prompt.lockStrength
            ]]
        }
        if let depth {
            payload["controlnets_depth"] = [[
                "path": "https://fal.run/controlnets/depth",
                "image_url": dataURI(depth),
                "strength": max(0.4, prompt.lockStrength - 0.2)
            ]]
        }

        let data = try await post(urlString: endpoint, key: key, payload: payload, timeout: timeout)
        guard let url = try? JSONDecoder().decode(FalImageResponse.self, from: data).images.first?.url,
              let rendered = try? UIImage(data: Data(contentsOf: URL(string: url)!)) else {
            throw CloudError(message: "Cloud render returned an unexpected response.")
        }
        return rendered
    }

    static func inpaint(image: UIImage, mask: CGImage, prompt: String,
                        useBYO: Bool, timeout: TimeInterval = 30) async throws -> UIImage {
        guard let key = BYOKeyManager.shared.falKey else {
            throw CloudError(message: "Editing needs an API key. Add one in Settings.")
        }
        let payload: [String: Any] = [
            "prompt": prompt,
            "image_url": dataURI(image),
            "mask_url": dataURI(mask),
            "num_inference_steps": 28,
            "output_format": "png"
        ]
        let data = try await post(urlString: "https://fal.run/fal-ai/flux/dev/image-to-image",
                                  key: key, payload: payload, timeout: timeout)
        guard let url = try? JSONDecoder().decode(FalImageResponse.self, from: data).images.first?.url,
              let edited = try? UIImage(data: Data(contentsOf: URL(string: url)!)) else {
            throw CloudError(message: "Cloud edit returned an unexpected response.")
        }
        return edited
    }

    private static func post(urlString: String, key: String, payload: [String: Any],
                             timeout: TimeInterval) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw CloudError(message: "Invalid endpoint.")
        }
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw CloudError(message: "Cloud service unavailable. Try again or use preview.")
        }
        return data
    }

    static func dataURI(_ image: UIImage) -> String {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return "" }
        return "data:image/jpeg;base64,\(data.base64EncodedString())"
    }

    static func dataURI(_ cgImage: CGImage) -> String {
        dataURI(UIImage(cgImage: cgImage))
    }
}

struct FalImageResponse: Codable {
    struct FalImage: Codable {
        let url: String
    }
    let images: [FalImage]
}
