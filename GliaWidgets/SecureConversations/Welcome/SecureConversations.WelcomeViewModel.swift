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
    typealias Props = SecureConversations.WelcomeViewController.Props
    typealias WelcomeViewProps = SecureConversations.WelcomeView.Props
    
    func props() -> Props {
        let welcomeStyle = environment.welcomeStyle
        let filePickerButton = SecureConversations.WelcomeView.Props.FilePickerButton(
            isEnabled: true,
            tap: Cmd { print("### file picker") }
        )

        let messageLenghtWarning = messageText.count > Self.messageTextLimit ? welcomeStyle
            .messageWarningStyle.messageLengthLimitText
            .withTextLength(String(SecureConversations.WelcomeViewModel.messageTextLimit))
        : ""

        let warningMessage = WelcomeViewProps.WarningMessage(
            text: messageLenghtWarning,
            animated: true
        )

        let sendMessageButton: WelcomeViewProps.SendMessageButton = .active(Cmd { print("### send message") })

        let props: Props = .welcome(
            .init(
                style: environment.welcomeStyle,
                backButtonTap: Cmd { [weak self] in self?.delegate?(.backTapped) },
                closeButtonTap: Cmd { [weak self] in self?.delegate?(.closeTapped) },
                checkMessageButtonTap: Cmd { print("### check messages") },
                filePickerButton: isAttachmentsAvailable ? filePickerButton : nil,
                sendMessageButton: sendMessageButton,
                messageTextViewProps: .init(
                    style: welcomeStyle.messageTextViewStyle,
                    text: messageText,
                    textChanged: .init { [weak self] text in
                        self?.messageText = text
                    }
                ),
                warningMessage: warningMessage
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
