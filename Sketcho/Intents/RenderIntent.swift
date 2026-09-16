import AppIntents
import SwiftData
import SwiftUI

struct RenderLastProjectIntent: AppIntent {
    static let title: LocalizedStringResource = "Render Last Room"
    static let description = IntentDescription("Render the most recent Sketcho project again.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .sketchoRenderLastProject, object: nil)
        return .result()
    }
}

struct SketchoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RenderLastProjectIntent(),
            phrases: [
                "Render my last room with \(.applicationName)",
                "Sketcho my sketch with \(.applicationName)",
                "Start a render in \(.applicationName)"
            ],
            shortTitle: "Render Last Room",
            systemImageName: "wand.and.stars"
        )
    }
}

extension Notification.Name {
    static let sketchoRenderLastProject = Notification.Name("sketchoRenderLastProject")
}
