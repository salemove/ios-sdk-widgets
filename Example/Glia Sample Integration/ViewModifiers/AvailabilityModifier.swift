import SwiftUI

struct IsAvailable: ViewModifier {
    let isAvailable: Bool

    init(_ isAvailable: Bool) {
        self.isAvailable = isAvailable
    }

    func body(content: Content) -> some View {
        content
            .disabled(!isAvailable)
            .opacity(isAvailable ? 1 : 0.5)
    }
}
