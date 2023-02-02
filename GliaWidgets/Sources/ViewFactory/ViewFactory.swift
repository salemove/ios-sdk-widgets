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

    func makeChatView() -> ChatView {
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
            )
        )
    }

    func makeCallView() -> CallView {
        return CallView(
            with: theme.call,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd,
                imageViewCache: environment.imageViewCache,
                timerProviding: environment.timerProviding,
                uiApplication: environment.uiApplication
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
}
