import SwiftUI

struct HeaderButtonSwiftUI: View {
    @ObservedObject var model: Model

    var body: some View {
        SwiftUI.Image(uiImage: model.style.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: model.size.width,
                height: model.size.height
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .foregroundColor(SwiftUI.Color(model.style.color))
            .opacity(model.isEnabled ? 1.0 : 0.6)
            .migrationAccessibilityLabel(model.style.accessibility.label)
            .migrationAccessibilityAddTrait(.isButton)
            .migrationAccessibilityRemoveTrait(.isImage)
            .migrationAccessibilityIdentifier(model.accessibilityIdentifier)
            .onTapGesture(perform: model.tap.execute)
    }
}

extension HeaderButtonSwiftUI {
    final class Model: ObservableObject {
        var tap: Cmd
        var style: HeaderButtonStyle
        var accessibilityIdentifier: String
        var size: CGSize
        var isEnabled: Bool
        var isHidden: Bool

        init(
            tap: Cmd = .nop,
            style: HeaderButtonStyle,
            accessibilityIdentifier: String,
            size: CGSize = CGSize(width: 14, height: 14),
            isEnabled: Bool,
            isHidden: Bool
        ) {
            self.tap = tap
            self.style = style
            self.size = size
            self.isEnabled = isEnabled
            self.isHidden = isHidden
            self.accessibilityIdentifier = accessibilityIdentifier
        }
    }
}
