import Foundation

extension SecureConversations {
    final class ConfirmationViewModel: ViewModel {
        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        var messageText: String { didSet { reportChange() } }

        init(environment: Environment) {
            self.environment = environment
            messageText = ""
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

extension SecureConversations.ConfirmationViewModel {
    func props() -> SecureConversations.ConfirmationViewController.Props {
        let confirmationStyle = environment.confirmationStyle
        let confirmationViewProps = SecureConversations.ConfirmationView.Props(
            style: confirmationStyle,
            header: Self.buildHeaderProps(
                style: confirmationStyle,
                backButtonCmd: Cmd(closure: { [weak self] in self?.delegate?(.backTapped) }),
                closeButtonCmd: Cmd(closure: { [weak self] in self?.delegate?(.closeTapped) })
            ),
            checkMessageButtonTap: Cmd { [weak self] in self?.delegate?(.chatTranscriptScreenRequested) }
        )

        let viewControllerProps = SecureConversations.ConfirmationViewController.Props(
            confirmationViewProps: confirmationViewProps
        )

        return viewControllerProps
    }

    static func buildHeaderProps(
        style: SecureConversations.ConfirmationStyle,
        backButtonCmd: Cmd,
        closeButtonCmd: Cmd
    ) -> Header.Props {
        let backButton = style.header.backButton.map { HeaderButton.Props(tap: backButtonCmd, style: $0) }

        return Header.Props(
            title: style.headerTitle,
            effect: .none,
            endButton: .init(style: style.header.endButton, accessibilityIdentifier: "header_end_button"),
            backButton: backButton,
            closeButton: .init(tap: closeButtonCmd, style: style.header.closeButton),
            endScreenshareButton: .init(style: style.header.endScreenShareButton),
            style: style.header
        )
    }
}

extension SecureConversations.ConfirmationViewModel {
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
        case renderProps(SecureConversations.ConfirmationViewController.Props)
        case chatTranscriptScreenRequested
    }

    enum StartAction {
        case none
    }
}

extension SecureConversations.ConfirmationViewModel {
    struct Environment {
        var confirmationStyle: SecureConversations.ConfirmationStyle
    }
}
