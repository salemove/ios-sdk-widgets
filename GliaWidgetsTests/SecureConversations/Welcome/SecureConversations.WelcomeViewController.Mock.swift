import Foundation
@testable import GliaWidgets

extension SecureConversations.WelcomeViewController.Props {
    static var mock: Self = {
        let viewFactory: ViewFactory = .mock()
        let welcomeStyle = viewFactory.theme.secureConversationsWelcomeStyle
        let filePickerButton = SecureConversations.WelcomeView.Props.FilePickerButton(
            isEnabled: true,
            tap: .nop
        )
        let messageTextViewProps = SecureConversations.WelcomeView.MessageTextView.Props.active(
            .init(
                style: viewFactory.theme.secureConversationsWelcomeStyle.messageTextViewStyle,
                text: "Test",
                textChanged: .nop,
                activeChanged: .nop
            )
        )

        return .welcome(
            .init(
                style: welcomeStyle,
                checkMessageButtonTap: .nop,
                filePickerButton: filePickerButton,
                sendMessageButton: SecureConversations.WelcomeView.Props.SendMessageButton.active(.nop),
                messageTextViewProps: messageTextViewProps,
                warningMessage: SecureConversations.WelcomeView.Props.WarningMessage(stringLiteral: ""),
                fileUploadListProps: SecureConversations.FileUploadListView.Props.mock,
                headerProps: .createNewProps(with: "", props: .mock()),
                isUiHidden: false
            )
        )
    }()
}
