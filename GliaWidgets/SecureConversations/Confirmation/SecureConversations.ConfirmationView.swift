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
            .setColor(model.style.confirmationImageTint)
            .padding(.bottom, model.orientation.isPortrait ? 32 : 8)
            .migrationAccessibilityHidden(true)
    }

    @ViewBuilder
    func titleView() -> some View {
        Text(model.style.titleStyle.text)
            .setFont(model.style.titleStyle.font)
            .multilineTextAlignment(.center)
            .setColor(model.style.titleStyle.color)
            .padding(.bottom, model.orientation.isPortrait ? 16 : 8)
    }

    @ViewBuilder
    func subtitleView() -> some View {
        Text(model.style.subtitleStyle.text)
            .setFont(model.style.subtitleStyle.font)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .setColor(model.style.subtitleStyle.color)
    }

    @ViewBuilder
    func confirmationButtonView() -> some View {
        SwiftUI.Button {
            model.event(.chatTranscriptScreenRequested)
        } label: {
            Text(model.style.checkMessagesButtonStyle.title)
                .setFont(model.style.checkMessagesButtonStyle.font)
                .multilineTextAlignment(.center)
                .setColor(model.style.checkMessagesButtonStyle.textColor)
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
        .migrationAccessibilityIdentifier("secureConversations_confirmationCheckMessages_button")
        .migrationAccessibilityLabel(model.style.checkMessagesButtonStyle.accessibility.label)
        .migrationAccessibilityHint(model.style.checkMessagesButtonStyle.accessibility.hint)
    }
}
