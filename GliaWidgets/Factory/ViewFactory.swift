import UIKit

class ViewFactory {
    let theme: Theme
    let environment: Environment

    init(
        with theme: Theme,
        environment: Environment
    ) {
        self.theme = theme
        self.environment = environment
    }

    func makeChatView() -> ChatView {
        return ChatView(
            with: theme.chat,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd
            )
        )
    }

    func makeCallView() -> CallView {
        return CallView(
            with: theme.call,
            environment: .init(
                data: environment.data,
                uuid: environment.uuid,
                gcd: environment.gcd
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
                gcd: environment.gcd
            )
        )
    }
}

extension ViewFactory {
    struct Environment {
        var data: FoundationBased.Data
        var uuid: () -> UUID
        var gcd: GCD
    }
}
