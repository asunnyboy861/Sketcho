import SwiftUI
import SwiftData

@main
struct SketchoApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Project.self, RenderVersion.self)
        } catch {
            fatalError("Failed to initialize Sketcho data: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
