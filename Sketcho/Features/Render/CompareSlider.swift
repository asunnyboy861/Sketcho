import SwiftUI

struct CompareSlider: View {
    let before: UIImage
    let after: UIImage

    @State private var position: CGFloat = 0.5

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(uiImage: after)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Image(uiImage: before)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .mask(
                        Rectangle()
                            .frame(width: geo.size.width * position)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )

                divider(in: geo)

                Text("Before")
                    .font(.caption2.weight(.semibold))
                    .padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                    .opacity(position > 0.15 ? 1 : 0)

                Text("After")
                    .font(.caption2.weight(.semibold))
                    .padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(10)
                    .opacity(position < 0.85 ? 1 : 0)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        position = min(1, max(0, value.location.x / geo.size.width))
                    }
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Before and after comparison. Drag horizontally to compare.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: position = min(1, position + 0.1)
            case .decrement: position = max(0, position - 0.1)
            @unknown default: break
            }
        }
    }

    private func divider(in geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(6)
                .background(Circle().fill(DesignSystem.amber))
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .position(x: geo.size.width * position, y: geo.size.height / 2)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 2)
                .position(x: geo.size.width * position, y: geo.size.height / 2)
        )
    }
}
