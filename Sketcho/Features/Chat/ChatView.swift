import SwiftUI
import SwiftData

struct ChatView: View {
    @ObservedObject var session: RenderSessionViewModel
    @Environment(\.modelContext) private var modelContext

    struct ChatEntry: Identifiable {
        let id = UUID()
        var role: Role
        var text: String
        var thumbnail: UIImage?

        enum Role { case user, system }
    }

    @State private var entries: [ChatEntry] = []
    @State private var input = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if entries.isEmpty {
                        ContentUnavailableView(
                            "Iterate conversationally",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Add instructions like \"walnut floor, dusk light\" and Sketcho renders a new version you can roll back to anytime.")
                        )
                    }
                    ForEach(entries) { entry in
                        chatBubble(entry)
                    }
                }
                .padding()
            }

            HStack(spacing: 10) {
                TextField("Describe a change…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                Button {
                    Task { await send() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(DesignSystem.amber)
                }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || session.isRendering)
                .accessibilityLabel("Send instruction")
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle("Iterate")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func chatBubble(_ entry: ChatEntry) -> some View {
        HStack(alignment: .bottom) {
            if entry.role == .user { Spacer(minLength: 40) }
            VStack(alignment: entry.role == .user ? .trailing : .leading, spacing: 6) {
                if let thumb = entry.thumbnail {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Text(entry.text)
                    .padding(12)
                    .background(entry.role == .user ? DesignSystem.amber.opacity(0.2) : DesignSystem.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            if entry.role == .system { Spacer(minLength: 40) }
        }
    }

    private func send() async {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        input = ""
        entries.append(ChatEntry(role: .user, text: text))
        session.instruction = text
        await session.render(quality: .preview, context: modelContext, project: nil)
        entries.append(ChatEntry(role: .system, text: "New version rendered · \(session.lastChannel.label)",
                                 thumbnail: session.currentResult))
    }
}
