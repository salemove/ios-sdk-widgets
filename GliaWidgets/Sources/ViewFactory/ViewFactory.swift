import UIKit

class ViewFactory {
    private(set) var theme: Theme
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

    func overrideTheme(with newTheme: Theme) {
        theme = newTheme
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
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen
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
        let backButton = theme.chat.header.backButton.map { HeaderButton.Props(tap: backCmd, style: $0) }

        return .init(
            header: .init(
                title: theme.chat.title,
                effect: .none,
                endButton: .init(style: theme.chat.header.endButton, tap: endCmd, accessibilityIdentifier: "header_end_button"),
                backButton: backButton,
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
                uiApplication: environment.uiApplication,
                uiScreen: environment.uiScreen
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
        let backButton = theme.call.header.backButton.map { HeaderButton.Props( tap: backCmd, style: $0) }

        return .init(
            header: .init(
                title: "",
                effect: .none,
                endButton: .init(style: theme.call.header.endButton, tap: endCmd, accessibilityIdentifier: "header_end_button"),
                backButton: backButton,
                closeButton: .init(tap: closeCmd, style: theme.call.header.closeButton),
                endScreenshareButton: .init(tap: endScreenshareCmd, style: theme.call.header.endScreenShareButton),
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

    func makeSecureConversationsWelcomeView(
        props: SecureConversations.WelcomeView.Props,
        environment: SecureConversations.WelcomeView.Environemnt
    ) -> SecureConversations.WelcomeView {
        return .init(props: props, environment: environment)
    }
}
