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

        static let sendMessageErrorAlertAccIdentidier = "send_message_alert_error_identifier"

        static let messageTextLimit = 10_000
        static let maximumUploads = 25

        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment

        var messageText: String = "" { didSet { reportChange() } }
        var isAttachmentsAvailable: Bool = true { didSet { reportChange() } }
        var isSecureConversationsAvailable: Bool = true { didSet { reportChange() } }
        var messageInputState: MessageInputState = .normal { didSet { reportChange() } }
        var sendMessageRequestState: SendMessageRequestState = .waiting { didSet { reportChange() } }

        let fileUploadListModel: FileUploadListViewModel

        lazy var sendMessageCommand = Cmd { [weak self] in
            self?.sendMessage()
        }

        init(environment: Environment) {
            self.environment = environment
            self.fileUploadListModel = environment.createFileUploadListModel(
                .init(
                    uploader: environment.fileUploader,
                    style: .messageCenter(environment.welcomeStyle.attachmentListStyle),
                    uiApplication: environment.uiApplication
                )
            )

            self.fileUploadListModel.delegate = { [weak self] event in
                switch event {
                case .renderProps:
                    self?.reportChange()
                }
            }

            checkSecureConversationsAvailability()
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
        let queueIds = environment.queueIds

        sendMessageRequestState = .loading

        _ = environment.sendSecureMessage(
            messageText,
            fileUploadListModel.attachment,
            queueIds
        ) { [weak self, alertConfiguration = environment.alertConfiguration] result in
            self?.sendMessageRequestState = .waiting

            switch result {
            case .success:
                self?.delegate?(.confirmationScreenRequested)
            case .failure:
                self?.delegate?(
                    .showAlert(
                        alertConfiguration.unexpectedError,
                        accessibilityIdentifier: Self.sendMessageErrorAlertAccIdentidier,
                        dismissed: nil
                    )
                )
            }
        }
    }

    func checkSecureConversationsAvailability() {
        environment.listQueues { [weak self] queues, _ in
            guard let self = self else {
                self?.isSecureConversationsAvailable = false
                return
            }

            self.isSecureConversationsAvailable = self.isSecureConversationsAvailable(in: queues)
        }
    }

    private func isSecureConversationsAvailable(
        in queues: [CoreSdkClient.Queue]?
    ) -> Bool {
        guard let queues = queues else { return false }

        let filteredQueues = queues
            .filter { self.environment.queueIds.contains($0.id) }
            .filter { $0.state.status != .closed }
            .filter { $0.state.media.contains(CoreSdkClient.MediaType.messaging) }

        return !filteredQueues.isEmpty
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

        let messageLenghtWarning = messageText.count > Self.messageTextLimit ? welcomeStyle
            .messageWarningStyle.messageLengthLimitText
            .withTextLength(String(SecureConversations.WelcomeViewModel.messageTextLimit))
        : ""

        let warningMessage = WelcomeViewProps.WarningMessage(
            text: messageLenghtWarning,
            animated: true
        )

        let sendMessageButton = Self.sendMessageButtonState(for: self)
        let props: Props = .welcome(
            .init(
                style: Self.welcomeStyle(for: self),
                checkMessageButtonTap: Cmd { [weak self] in self?.delegate?(.transcriptRequested) },
                filePickerButton: Self.filePickerButtonState(for: self),
                sendMessageButton: sendMessageButton,
                messageTextViewProps: Self.textViewState(for: self),
                warningMessage: warningMessage,
                fileUploadListProps: fileUploadListModel.props(),
                headerProps: Self.headerState(for: self, with: welcomeStyle)
            )
        )
        return props
    }

    static func welcomeStyle(
        for instance: SecureConversations.WelcomeViewModel
    ) -> SecureConversations.WelcomeStyle {
        var style = instance.environment.welcomeStyle

        if !instance.isSecureConversationsAvailable {
            style.messageTitleStyle = nil
        }

        return style
    }

    static func filePickerButtonState(
        for instance: SecureConversations.WelcomeViewModel
    ) -> WelcomeViewProps.FilePickerButton? {
        var filePickerButton: WelcomeViewProps.FilePickerButton?

        let isFilePickerEnabled = !instance.fileUploadListModel.isLimitReached
        if instance.isSecureConversationsAvailable && instance.isAttachmentsAvailable {
            filePickerButton = WelcomeViewProps.FilePickerButton(
                isEnabled: isFilePickerEnabled,
                tap: Command { originView in
                    instance.presentMediaPicker(
                        from: originView,
                        alertConfiguration: instance.environment.alertConfiguration
                    )
                }
            )
        }

        return filePickerButton
    }
    static func textViewState(for instance: SecureConversations.WelcomeViewModel
    ) -> TextViewProps? {
        guard instance.isSecureConversationsAvailable else {
            return nil
        }

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
    ) -> SendMessageButton? {
        // Is service available?
        guard instance.isSecureConversationsAvailable else {
            return nil
        }

        // Are there failed uploads?
        guard instance.fileUploadListModel.failedUploads.isEmpty else {
            return .disabled
        }

        // Are there in-progress uploads?
        guard instance.fileUploadListModel.activeUploads.isEmpty else {
            return .disabled
        }

        // Is message text valid?
        guard isInputTextValid(instance.messageText) else {
            return .disabled
        }

        // Is there a ticket?
        guard !instance.environment.queueIds.isEmpty else {
            return .disabled
        }

        switch instance.sendMessageRequestState {
        case .loading:
            return .loading
        case .waiting:
            return .active(instance.sendMessageCommand)
        }
    }

    static func isInputTextValid(_ text: String) -> Bool {
        guard !text.isEmpty else {
            return false
        }

        return text.count <= Self.messageTextLimit
    }

    static func headerState(
        for instance: SecureConversations.WelcomeViewModel,
        with style: SecureConversations.WelcomeStyle
    ) -> Header.Props {
        .init(
            title: style.headerTitle,
            effect: .none,
            endButton: .init(),
            backButton: .init(tap: Cmd { [weak instance] in instance?.delegate?(.backTapped) }, style: style.header.backButton),
            closeButton: .init(tap: Cmd { [weak instance] in instance?.delegate?(.closeTapped) }, style: style.header.closeButton),
            endScreenshareButton: .init(style: style.header.endScreenShareButton),
            style: style.header
        )
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
        case confirmationScreenRequested
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
        case transcriptRequested
    }

    enum StartAction {
        case none
    }
}

extension SecureConversations.WelcomeViewModel {
    struct Environment {
        var welcomeStyle: SecureConversations.WelcomeStyle
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
        var alertConfiguration: AlertConfiguration
        var fileUploader: FileUploader
        var uiApplication: UIKitBased.UIApplication
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
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
        fileUploadListModel.addUpload(with: url)
    }

    private func addUpload(
        with data: Data,
        format: MediaFormat
    ) {
        fileUploadListModel.addUpload(
            with: data,
            format: format
        )
    }

    private func removeUpload(_ upload: FileUpload) {
        fileUploadListModel.removeUpload(upload)
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
