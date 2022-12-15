import Foundation

extension SecureConversations {
    final class WelcomeViewModel: ViewModel {
        static let messageTextLimit = 10_000

        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        var messageText: String = "" { didSet { reportChange() } }
        var isAttachmentsAvailable: Bool = true { didSet { reportChange() } }

        init(environment: Environment) {
            self.environment = environment
        }

        func event(_ event: Event) {
            switch event {
            case .backTapped:
                delegate?(.backTapped)
            case .closeTapped:
                delegate?(.closeTapped)
            }
        }

        func reportChange() {
            delegate?(.renderProps(props()))
        }
    }
}

extension SecureConversations.WelcomeViewModel {
    func props() -> SecureConversations.WelcomeViewController.Props {
        let welcomeStyle = environment.welcomeStyle
        let filePickerButtonTap = Cmd { print("### file picker") }
        let props: SecureConversations.WelcomeViewController.Props = .welcome(
            .init(
                style: environment.welcomeStyle,
                backButtonTap: Cmd { [weak self] in self?.delegate?(.backTapped) },
                closeButtonTap: Cmd { [weak self] in self?.delegate?(.closeTapped) },
                checkMessageButtonTap: Cmd { print("### check messages") },
                filePickerButtonTap: isAttachmentsAvailable ? filePickerButtonTap : nil,
                sendMessageButtonTap: Cmd { print("### send message") },
                messageTextViewProps: .init(
                    style: welcomeStyle.messageTextViewStyle,
                    text: messageText,
                    textChanged: .init { [weak self] text in
                        self?.messageText = text
                    },
                    textLimit: Self.messageTextLimit
                )
            )
        )
        return props
    }
}

extension SecureConversations.WelcomeViewModel {
    enum Event {
        case backTapped
        case closeTapped
    }

    enum Action {
        case start
    }

    enum DelegateEvent {
        case backTapped
        case closeTapped
        case renderProps(SecureConversations.WelcomeViewController.Props)
    }

    enum StartAction {
        case none
    }
}

extension SecureConversations.WelcomeViewModel {
    struct Environment {
        var welcomeStyle: SecureConversations.WelcomeStyle
    }
}
