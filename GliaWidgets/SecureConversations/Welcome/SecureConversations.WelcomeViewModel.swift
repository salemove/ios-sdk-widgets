import Foundation

extension SecureConversations {
    final class WelcomeViewModel: ViewModel {
        enum MessageInputState {
            case normal, active, disabled
        }

        static let messageTextLimit = 10_000

        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        var messageText: String = "" { didSet { reportChange() } }
        var isAttachmentsAvailable: Bool = true { didSet { reportChange() } }
        var messageInputState: MessageInputState = .normal { didSet { reportChange() } }

        lazy var sendMessageCommand = Cmd { [weak self] in
            guard
                let message = self?.messageText,
                    !message.isEmpty
            else {
                // TODO: show error
                return
            }

            guard
                let queueIds = self?.environment.queueIds,
                    !queueIds.isEmpty
            else {
                // TODO: show error
                return
            }

            _ = self?.environment.sendSecureMessage(message, nil, queueIds) { result in
                switch result {
                case .success(let message):
                    // TODO: go to confirmation screen
                    print("Success sending message with content: \(message.content)")
                case .failure:
                    // TODO: show error
                    print("### failure sending secure message")
                }
            }
        }

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
    typealias TextViewProps = SecureConversations.WelcomeView.MessageTextView.Props

    // At one hand it is convenient to have Props construction logic in single place,
    // but since the method can become quite big (resulting in linter warnings),
    // some parts are refactored to pure static methods.
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

        let sendMessageButton: WelcomeViewProps.SendMessageButton = .active(sendMessageCommand)

        let props: Props = .welcome(
            .init(
                style: environment.welcomeStyle,
                backButtonTap: Cmd { [weak self] in self?.delegate?(.backTapped) },
                closeButtonTap: Cmd { [weak self] in self?.delegate?(.closeTapped) },
                checkMessageButtonTap: Cmd { print("### check messages") },
                filePickerButton: isAttachmentsAvailable ? filePickerButton : nil,
                sendMessageButton: sendMessageButton,
                messageTextViewProps: Self.textViewState(for: self),
                warningMessage: warningMessage
            )
        )
        return props
    }

    static func textViewState(for instance: SecureConversations.WelcomeViewModel
    ) -> TextViewProps {
        let messageTextViewStyle = instance.environment.welcomeStyle.messageTextViewStyle
        let normalTextViewState = TextViewProps.NormalState(
            style: messageTextViewStyle,
            text: instance.messageText,
            activeChanged: .init { [weak instance] isActive in
                if isActive {
                    instance?.messageInputState = .active
                }
            }
        )

        let activeTextViewState = TextViewProps.ActiveState(
            style: messageTextViewStyle,
            text: instance.messageText,
            textChanged: .init { [weak instance] text in
                instance?.messageText = text
            },
            activeChanged: .init { [weak instance] isActive in
                if !isActive {
                    instance?.messageInputState = .normal
                }
            }
        )

        let disabledTextViewState = TextViewProps.DisabledState(
            style: messageTextViewStyle,
            text: instance.messageText
        )

        let textViewState: TextViewProps

        switch instance.messageInputState {
        case .normal:
            textViewState = .normal(normalTextViewState)
        case .active:
            textViewState = .active(activeTextViewState)
        case .disabled:
            textViewState = .disabled(disabledTextViewState)
        }

        return textViewState
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
        var queueIds: [String]
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
    }
}
