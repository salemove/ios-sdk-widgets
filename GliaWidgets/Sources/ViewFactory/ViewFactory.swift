import UIKit

class ViewFactory {
    let theme: Theme
    let environment: Environment
    let messageRenderer: MessageRenderer?

    init(
        with theme: Theme,
        messageRenderer: MessageRenderer?,
        environment: Environment
    ) {
        self.theme = theme
        self.messageRenderer = messageRenderer
        self.environment = environment
    }

    func makeChatView(
        endCmd: Cmd,
        closeCmd: Cmd,
        endScreenshareCmd: Cmd,
        backCmd: Cmd
    ) -> ChatView {
        return ChatView(
            with: theme.chat,
            messageRenderer: messageRenderer,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication
            ),
            props: Self.chatHeaderProps(
                theme: theme,
                endCmd: endCmd,
                closeCmd: closeCmd,
                endScreenshareCmd: endScreenshareCmd,
                backCmd: backCmd
            )
        )
    }

    static func chatHeaderProps(
        theme: Theme,
        endCmd: Cmd,
        closeCmd: Cmd,
        endScreenshareCmd: Cmd,
        backCmd: Cmd
    ) -> ChatView.Props {
        .init(
            header: .init(
                title: theme.chat.title,
                effect: .none,
                endButton: .init(style: theme.chat.header.endButton, tap: endCmd),
                backButton: .init(tap: backCmd, style: theme.chat.header.backButton),
                closeButton: .init(tap: closeCmd, style: theme.chat.header.closeButton),
                endScreenshareButton: .init(tap: endScreenshareCmd, style: theme.chat.header.endScreenShareButton),
                style: theme.chat.header
            )
        )
    }

    func makeCallView(
        endCmd: Cmd,
        closeCmd: Cmd,
        endScreenshareCmd: Cmd,
        backCmd: Cmd
    ) -> CallView {
        return CallView(
            with: theme.call,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication
            ),
            props: Self.callHeaderProps(
                theme: theme,
                endCmd: endCmd,
                closeCmd: closeCmd,
                endScreenshareCmd: endScreenshareCmd,
                backCmd: backCmd
            )
        )
    }

    static func callHeaderProps(
        theme: Theme,
        endCmd: Cmd,
        closeCmd: Cmd,
        endScreenshareCmd: Cmd,
        backCmd: Cmd
    ) -> CallView.Props {
        .init(
            header: .init(
                title: "",
                effect: .none,
                endButton: .init(style: theme.call.header.endButton, tap: endCmd),
                backButton: .init(tap: backCmd, style: theme.call.header.backButton),
                closeButton: .init(tap: closeCmd, style: theme.call.header.closeButton),
                endScreenshareButton: .init(style: theme.call.header.endScreenShareButton),
                style: theme.call.header
            )
        )
    }

    func makeAlertView() -> AlertView {
        return AlertView(with: theme.alert)
    }

    func makeBubbleView() -> BubbleView {
        return BubbleView(
            with: theme.minimizedBubble,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache
            )
        )
    }

    func makeSecureConversationsWelcomeView(props: SecureConversations.WelcomeView.Props) -> SecureConversations.WelcomeView {
        return .init(props: props)
    }

    func makeSecureConversationsConfirmationView(props: SecureConversations.ConfirmationView.Props) -> SecureConversations.ConfirmationView {
        return .init(props: props)
    }
}
