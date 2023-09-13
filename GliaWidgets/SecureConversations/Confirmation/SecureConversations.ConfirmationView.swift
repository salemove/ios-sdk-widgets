import SwiftUI

extension SecureConversations {
    struct ConfirmationViewSwiftUI: View {
        @ObservedObject var model: Model

        var body: some View {
            ZStack {
                backgroundColor()
                VStack(spacing: 0) {
                    HeaderSwiftUI(model: model.makeHeaderModel())
                    VStack(spacing: 0) {
                        Spacer(minLength: 1)
                        checkmarkImage()
                        titleView()
                        subtitleView()
                        Spacer(minLength: 1)
                        confirmationButtonView()
                    }
                    .padding(.bottom, model.orientation.isPortrait ? 24 : 8)
                    .padding(.horizontal, 24)
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
    }
}

private extension SecureConversations.ConfirmationViewSwiftUI {
    @ViewBuilder
    func backgroundColor() -> some View {
        SwiftUI.Color(model.style.backgroundColor)
            .edgesIgnoringSafeArea(.all)
    }
    @ViewBuilder
    func checkmarkImage() -> some View {
        SwiftUI.Image(uiImage: Asset.mcConfirmation.image.withRenderingMode(.alwaysTemplate))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: model.orientation.isPortrait ? 100.0 : 70.0)
            .foregroundColor(SwiftUI.Color(model.style.confirmationImageTint))
            .padding(.bottom, model.orientation.isPortrait ? 32 : 8)
            .accessibility(hidden: true)
    }

    @ViewBuilder
    func titleView() -> some View {
        Text(model.style.titleStyle.text)
            .font(.convert(model.style.titleStyle.font))
            .multilineTextAlignment(.center)
            .foregroundColor(SwiftUI.Color(model.style.titleStyle.color))
            .padding(.bottom, model.orientation.isPortrait ? 16 : 8)
    }

    @ViewBuilder
    func subtitleView() -> some View {
        Text(model.style.subtitleStyle.text)
            .font(.convert(model.style.subtitleStyle.font))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .foregroundColor(SwiftUI.Color(model.style.subtitleStyle.color))
    }

    @ViewBuilder
    func confirmationButtonView() -> some View {
        SwiftUI.Button {
            model.event(.chatTranscriptScreenRequested)
        } label: {
            Text(model.style.checkMessagesButtonStyle.title)
                .font(.convert(model.style.checkMessagesButtonStyle.font))
                .multilineTextAlignment(.center)
                .foregroundColor(SwiftUI.Color(model.style.checkMessagesButtonStyle.textColor))
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 48,
                    idealHeight: 48
                )
                .background(SwiftUI.Color(model.style.checkMessagesButtonStyle.backgroundColor))
                .cornerRadius(4)
        }
        .accessibility(identifier: "secureConversations_confirmationCheckMessages_button")
        .accessibility(label: Text(model.style.checkMessagesButtonStyle.accessibility.label))
        .accessibility(hint: Text(model.style.checkMessagesButtonStyle.accessibility.hint))
    }
}
