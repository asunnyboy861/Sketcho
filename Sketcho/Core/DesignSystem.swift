import SwiftUI

enum DesignSystem {
    static let amber = Color(red: 1.0, green: 0.624, blue: 0.039)
    static let amberDim = Color(red: 0.55, green: 0.36, blue: 0.05)
    static let charcoal = Color(red: 0.09, green: 0.09, blue: 0.10)
    static let cardBackground = Color(.secondarySystemBackground)
    static let separator = Color(.separator)
}

extension View {
    func sketchoCard() -> some View {
        self
            .padding(16)
            .background(DesignSystem.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
