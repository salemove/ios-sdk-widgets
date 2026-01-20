import SwiftUI

struct ActionButtonSwiftUI: View {
    static let edgeInsets: EdgeInsets = .init(top: 6, leading: 16, bottom: 6, trailing: 16)
    @ObservedObject var model: Model

    var body: some View {
        Text(model.style.title)
            .setFont(model.style.titleFont, textStyle: model.style.textStyle)
            .setColor(model.style.titleColor)
            .padding(Self.edgeInsets)
            .applyColorTypeBackground(model.style.backgroundColor)
            .cornerRadius(model.style.cornerRaidus ?? 0)
            .overlay(
                RoundedRectangle(cornerRadius: model.style.cornerRaidus ?? 0)
                .stroke(
                    SwiftUI.Color(model.style.borderColor ?? .clear),
                    lineWidth: model.style.borderWidth ?? 0
                )
            )
            .shadow(
                color: SwiftUI.Color(model.style.shadowColor ?? .clear),
                radius: model.style.shadowRadius ?? 0,
                x: model.style.shadowOffset?.width ?? 0,
                y: model.style.shadowOffset?.height ?? 0
            )
            .migrationAccessibilityIdentifier(model.accessibilityIdentifier)
            .migrationAccessibilityAddTrait(.isButton)
            .migrationAccessibilityRemoveTrait(.isImage)
            .onTapGesture(perform: model.tap.execute)
    }
}

extension ActionButtonSwiftUI {
    final class Model: ObservableObject {
        let style: ActionButtonStyle
        let height: CGFloat
        let tap: Cmd
        let accessibilityIdentifier: String
        @Published var isEnabled: Bool
        @Published var isHidden: Bool

        init(
            style: ActionButtonStyle = .init(
                title: "",
                titleFont: .systemFont(ofSize: 16),
                titleColor: .white,
                backgroundColor: .fill(color: .blue)
            ),
            height: CGFloat = 40,
            tap: Cmd = .nop,
            accessibilityIdentifier: String = "",
            isEnabled: Bool,
            isHidden: Bool
        ) {
            self.style = style
            self.height = height
            self.tap = tap
            self.accessibilityIdentifier = accessibilityIdentifier.isEmpty ? style.title : accessibilityIdentifier
            self.isEnabled = isEnabled
            self.isHidden = isHidden
        }
    }
}
