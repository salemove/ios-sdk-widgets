import Foundation
import UIKit

extension SecureConversations {
    final class WelcomeViewModel: ViewModel {
        enum MessageInputState {
            case normal, active, disabled
        }

        enum SendMessageRequestState {
            case waiting, loading
        }

        static let messageTextLimit = 10_000
        static let maximumUploads = 25

        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        var messageText: String = "" { didSet { reportChange() } }
        var isAttachmentsAvailable: Bool = true { didSet { reportChange() } }
        var messageInputState: MessageInputState = .normal { didSet { reportChange() } }
        var sendMessageRequestState: SendMessageRequestState = .waiting { didSet { reportChange() } }

        let fileUploadListModel: FileUploadListViewModel

        lazy var sendMessageCommand = Cmd { [weak self] in
            self?.sendMessage()
        }

        init(environment: Environment) {
            self.environment = environment
            self.fileUploadListModel = .init(
                environment: .init(
                        uploader: environment.fileUploader,
                        style: environment.welcomeStyle.attachmentListStyle,
                        uiApplication: environment.uiApplication
                    )
                )
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

// MARK: - Send Message
private extension SecureConversations.WelcomeViewModel {
    func sendMessage() {
        guard !messageText.isEmpty else { return }

        let queueIds = environment.queueIds
        guard !queueIds.isEmpty else {
            // TODO: show error
            return
        }

        sendMessageRequestState = .loading

        _ = environment.sendSecureMessage(messageText, nil, queueIds) { [weak self] result in
            self?.sendMessageRequestState = .waiting

            switch result {
            case .success:
                self?.delegate?(.confirmationScreenNeeded)
            case .failure(let error):
                // TODO: show error
                print("error on sending message")
            }
        }
    }
}
// MARK: - Props Generation
extension SecureConversations.WelcomeViewModel {
    typealias Props = SecureConversations.WelcomeViewController.Props
    typealias WelcomeViewProps = SecureConversations.WelcomeView.Props
    typealias TextViewProps = SecureConversations.WelcomeView.MessageTextView.Props
    typealias SendMessageButton = WelcomeViewProps.SendMessageButton

    // At one hand it is convenient to have Props construction logic in single place,
    // but since the method can become quite big (resulting in linter warnings),
    // some parts are refactored to pure static methods.
    func props() -> Props {
        let welcomeStyle = environment.welcomeStyle
        let filePickerButton = SecureConversations.WelcomeView.Props.FilePickerButton(
            isEnabled: true,
            tap: Command { [weak self, alertConfiguration = environment.alertConfiguration] originView in
                self?.presentMediaPicker(
                    from: originView,
                    alertConfiguration: alertConfiguration
                )
            }
        )

        let messageLenghtWarning = messageText.count > Self.messageTextLimit ? welcomeStyle
            .messageWarningStyle.messageLengthLimitText
            .withTextLength(String(SecureConversations.WelcomeViewModel.messageTextLimit))
        : ""

        let warningMessage = WelcomeViewProps.WarningMessage(
            text: messageLenghtWarning,
            animated: true
        )

        let sendMessageButton: SendMessageButton = Self.sendMessageButtonState(for: self)

        let props: Props = .welcome(
            .init(
                style: environment.welcomeStyle,
                backButtonTap: Cmd { [weak self] in self?.delegate?(.backTapped) },
                closeButtonTap: Cmd { [weak self] in self?.delegate?(.closeTapped) },
                checkMessageButtonTap: Cmd { print("### check messages") },
                filePickerButton: isAttachmentsAvailable ? filePickerButton : nil,
                sendMessageButton: sendMessageButton,
                messageTextViewProps: Self.textViewState(for: self),
                warningMessage: warningMessage,
                fileUploadListProps: fileUploadListModel.props()
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

    static func sendMessageButtonState(
        for instance: SecureConversations.WelcomeViewModel
    ) -> SendMessageButton {
        switch instance.sendMessageRequestState {
        case .loading:
            return .loading
        case .waiting:
            return .active(instance.sendMessageCommand)
        }
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
        case confirmationScreenNeeded
        case mediaPickerRequested(
            from: UIView,
            callback: (AttachmentSourceItemKind) -> Void
        )
        case pickMedia(Command<MediaPickerEvent>)
        case takeMedia(Command<MediaPickerEvent>)
        case pickFile(Command<FilePickerEvent>)
        case showFile(LocalFile)
        case showAlert(
            MessageAlertConfiguration,
            accessibilityIdentifier: String?,
            dismissed: (() -> Void)?
        )
        case showSettingsAlert(
            SettingsAlertConfiguration,
            cancelled: (() -> Void)?
        )
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
        var alertConfiguration: AlertConfiguration
        var fileUploader: FileUploader
        var uiApplication: UIKitBased.UIApplication
    }
}

// MARK: - Media Picker
extension SecureConversations.WelcomeViewModel {
    func presentMediaPicker(
        from originView: UIView,
        alertConfiguration: AlertConfiguration
    ) {
        let itemSelected = { (kind: AttachmentSourceItemKind) -> Void in
            let media = Command<MediaPickerEvent> { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .none, .cancelled:
                    break
                case .pickedMedia(let media):
                    self.mediaPicked(media)
                case .sourceNotAvailable:
                    self.showAlert(
                        with: alertConfiguration.mediaSourceNotAvailable,
                        dismissed: nil
                    )
                case .noCameraPermission:
                    self.showSettingsAlert(with: alertConfiguration.cameraSettings)
                }
            }
            let file = Command<FilePickerEvent> { [weak self] event in
                switch event {
                case .none, .cancelled:
                    break
                case .pickedFile(let url):
                    self?.filePicked(url)
                }
            }

            switch kind {
            case .photoLibrary:
                self.delegate?(.pickMedia(media))
            case .takePhoto:
                self.delegate?(.takeMedia(media))
            case .browse:
                self.delegate?(.pickFile(file))
            }
        }

        delegate?(
            .mediaPickerRequested(
                from: originView,
                callback: itemSelected
            )
        )
    }

    private func mediaPicked(_ media: PickedMedia) {
        switch media {
        case .image(let url):
            addUpload(with: url)
        case .photo(let data, format: let format):
            addUpload(with: data, format: format)
        case .movie(let url):
            addUpload(with: url)
        case .none:
            break
        }
    }

    func showAlert(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String? = nil,
        dismissed: (() -> Void)? = nil
    ) {
        let onDismissed = {
            Self.alertPresenters.remove(self)
            dismissed?()
        }
        Self.alertPresenters.insert(self)
        delegate?(
            .showAlert(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: { onDismissed() }
            )
        )
    }

    func showSettingsAlert(
        with conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)? = nil
    ) {
        delegate?(
            .showSettingsAlert(
                conf,
                cancelled: cancelled
            )
        )
    }

    func filePicked(_ url: URL) {
        addUpload(with: url)
    }
}

// MARK: - Upload releated methods
extension SecureConversations.WelcomeViewModel {
    private func addUpload(with url: URL) {
        // TODO: MOB-1722
    }

    private func addUpload(with data: Data, format: MediaFormat) {
        // TODO: MOB-1722
    }

    private func removeUpload(_ upload: FileUpload) {
        // TODO: MOB-1722
    }

    private func onUploaderStateChanged(_ state: FileUploader.State) {
        // TODO: MOB-1722
    }

    private func fileTapped(_ file: LocalFile) {
        delegate?(.showFile(file))
    }
}

// MARK: Support alerts system
extension SecureConversations.WelcomeViewModel {
    private static var alertPresenters = Set<SecureConversations.WelcomeViewModel>()
}

extension SecureConversations.WelcomeViewModel: Hashable {
    static func == (lhs: SecureConversations.WelcomeViewModel, rhs: SecureConversations.WelcomeViewModel) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
