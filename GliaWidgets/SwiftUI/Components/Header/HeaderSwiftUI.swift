import SwiftUI

struct HeaderSwiftUI: View {
    @ObservedObject var model: Model

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 16) {
                if let backButton = model.backButton {
                    HeaderButtonSwiftUI(model: backButton)
                }

                Spacer()
                if !model.endButton.isHidden {
                    ActionButtonSwiftUI(model: model.endButton)
                }

                if !model.endScreenshareButton.isHidden {
                    HeaderButtonSwiftUI(model: model.endScreenshareButton)
                }

                if !model.closeButton.isHidden {
                    HeaderButtonSwiftUI(model: model.closeButton)
                }
            }
            Text(model.title)
                .font(.convert(model.style.titleFont))
                .foregroundColor(SwiftUI.Color(model.style.titleColor))
                .accessibility(identifier: "header_view_title_label")
                .accessibility(label: Text(model.title))
                .accessibility(addTraits: .isHeader)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .frame(
            height: 58 + (model.environment.uiApplication.windows().first?.safeAreaInsets.top ?? 0),
            alignment: .bottom
        )
        .background(SwiftUI.Color(model.style.backgroundColor.color))
        .edgesIgnoringSafeArea([.leading, .trailing])
    }
}

extension HeaderSwiftUI {
    final class Model: ObservableObject {
        let title: String
        let effect: Effect
        let endButton: ActionButtonSwiftUI.Model
        let backButton: HeaderButtonSwiftUI.Model?
        let closeButton: HeaderButtonSwiftUI.Model
        let endScreenshareButton: HeaderButtonSwiftUI.Model
        let style: HeaderStyle
        let environment: Environment

        init(
            title: String,
            effect: Effect,
            endButton: ActionButtonSwiftUI.Model,
            backButton: HeaderButtonSwiftUI.Model?,
            closeButton: HeaderButtonSwiftUI.Model,
            endScreenshareButton: HeaderButtonSwiftUI.Model,
            style: HeaderStyle,
            environment: Environment
        ) {
            self.title = title
            self.effect = effect
            self.endButton = endButton
            self.backButton = backButton
            self.closeButton = closeButton
            self.endScreenshareButton = endScreenshareButton
            self.style = style
            self.environment = environment
        }
    }
}

extension HeaderSwiftUI {
    enum Effect {
        case none
        case blur
    }

    struct Environment {
        let uiApplication: UIKitBased.UIApplication
    }
}
