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

        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment
        var availability: Availability

        var messageText: String = "" { didSet { reportChange() } }
        /// Flag indicating attachment(s) availability.
        /// By default attachments are not available, until site configurations are fetched.
        private(set) var isAttachmentsAvailable: Bool = false { didSet { reportChange() } }
        var availabilityStatus: Availability.Status = .available(.queues(queueIds: [])) { didSet { reportChange() } }
        var messageInputState: MessageInputState = .normal { didSet { reportChange() } }
        var sendMessageRequestState: SendMessageRequestState = .waiting { didSet { reportChange() } }

        let fileUploadListModel: FileUploadListViewModel

        lazy var sendMessageCommand = Cmd { [weak self] in
            self?.sendMessage()
        }

        init(
            environment: Environment,
            availability: Availability,
            delegate: ((DelegateEvent) -> Void)? = nil
        ) {
            self.delegate = delegate
            self.environment = environment
            self.fileUploadListModel = environment.createFileUploadListModel(
                .init(
                    uploader: environment.fileUploader,
                    style: .messageCenter(environment.welcomeStyle.attachmentListStyle),
                    scrollingBehaviour: .nonScrolling
                )
            )
            self.availability = availability

            self.fileUploadListModel.delegate = { [weak self] event in
                switch event {
                case .renderProps:
                    self?.reportChange()
                }
            }

            checkSecureConversationsAvailability()
            loadAttachmentAvailability()
            environment.startSocketObservation()
        }

        private func checkSecureConversationsAvailability() {
            availability.checkSecureConversationsAvailability(for: environment.queueIds) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(.available(.queues(queueIds))):
                    self.environment.queueIds = queueIds
                    self.availabilityStatus = .available(.queues(queueIds: queueIds))
                case .success(.available(.transferred)):
                    self.environment.queueIds = []
                    self.availabilityStatus = .available(.transferred)
                case .success(.unavailable(.emptyQueue)), .failure:
                    self.availabilityStatus = .unavailable(.emptyQueue)
                    self.delegate?(.showAlert(.unavailableMessageCenter()))
                case .success(.unavailable(.unauthenticated)):
                    self.availabilityStatus = .unavailable(.unauthenticated)
                    self.delegate?(.showAlert(.unavailableMessageCenterForBeingUnauthenticated()))
                }
            }
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

        deinit {
            environment.stopSocketObservation()
        }
    }
}

// MARK: - Send Message
private extension SecureConversations.WelcomeViewModel {
    func sendMessage() {
        let queueIds = environment.queueIds

        sendMessageRequestState = .loading

        let payload = environment.createSendMessagePayload(
            messageText,
            fileUploadListModel.attachment
        )

        _ = environment.sendSecureMessagePayload(
            payload,
            queueIds
        ) { [weak self] result in
            self?.sendMessageRequestState = .waiting

            switch result {
            case .success:
                self?.delegate?(.confirmationScreenRequested)
            case let .failure(error):
                self?.delegate?(.showAlert(.error(error: error)))
            }
        }
    }
    func loadAttachmentAvailability() {
        environment.fetchSiteConfigurations { [weak self] result in
            switch result {
            case let .success(site):
                self?.isAttachmentsAvailable = site.allowedFileSenders.visitor
            case let .failure(error):
                self?.delegate?(.showAlert(.error(error: error)))
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
                headerProps: Self.headerState(for: self, with: welcomeStyle),
                isUiHidden: self.availabilityStatus == .unavailable(.unauthenticated)
            )
        )
        return props
    }

    static func welcomeStyle(
        for instance: SecureConversations.WelcomeViewModel
    ) -> SecureConversations.WelcomeStyle {
        var style = instance.environment.welcomeStyle

        if !instance.availabilityStatus.isAvailable {
            style.messageTitleStyle = nil
        }

        return style
    }

    static func filePickerButtonState(
        for instance: SecureConversations.WelcomeViewModel
    ) -> WelcomeViewProps.FilePickerButton? {
        var filePickerButton: WelcomeViewProps.FilePickerButton?

        let isFilePickerEnabled = !instance.fileUploadListModel.isLimitReached
        if instance.availabilityStatus.isAvailable, instance.isAttachmentsAvailable {
            filePickerButton = WelcomeViewProps.FilePickerButton(
                isEnabled: isFilePickerEnabled,
                tap: Command { originView in
                    instance.presentMediaPicker(from: originView)
                }
            )
        }

        return filePickerButton
    }
    static func textViewState(for instance: SecureConversations.WelcomeViewModel) -> TextViewProps? {
        guard instance.availabilityStatus.isAvailable else {
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
        guard instance.availabilityStatus.isAvailable else {
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

        // Is file upload limit not yet reached?
        guard !instance.fileUploadListModel.isLimitReached else {
            return .disabled
        }

        // Is message text valid or have attachments been successfully uploaded?
        guard
            isInputTextValid(instance.messageText) ||
            !instance.fileUploadListModel.succeededUploads.isEmpty
        else {
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
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        return text.count <= Self.messageTextLimit
    }

    static func headerState(
        for instance: SecureConversations.WelcomeViewModel,
        with style: SecureConversations.WelcomeStyle
    ) -> Header.Props {
        let backButton = style.header.backButton.map {
            HeaderButton.Props(
                tap: Cmd { [weak instance] in instance?.delegate?(.backTapped) },
                style: $0
            )
        }

        return .init(
            title: style.headerTitle,
            effect: .none,
            endButton: .init(),
            backButton: backButton,
            closeButton: .init(
                tap: Cmd { [weak instance] in instance?.delegate?(.closeTapped) },
                style: style.header.closeButton
            ),
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
        case showAlert(AlertInputType)
        case transcriptRequested
    }

    enum StartAction {
        case none
    }
}

// MARK: - Media Picker
extension SecureConversations.WelcomeViewModel {
    func presentMediaPicker(from originView: UIView) {
        let itemSelected = { (kind: AttachmentSourceItemKind) in
            let media = Command<MediaPickerEvent> { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .none, .cancelled:
                    break
                case .pickedMedia(let media):
                    self.mediaPicked(media)
                case .sourceNotAvailable:
                    self.delegate?(.showAlert(.mediaSourceNotAvailable()))
                case .noCameraPermission:
                    self.delegate?(.showAlert(.cameraSettings()))
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

    func filePicked(_ url: URL) {
        addUpload(with: url)
    }
}

// MARK: - Upload releated methods
extension SecureConversations.WelcomeViewModel {
    private func addUpload(with url: URL) {
        determineFileUploadEndpoint()
        fileUploadListModel.addUpload(with: url)
    }

    private func addUpload(
        with data: Data,
        format: MediaFormat
    ) {
        determineFileUploadEndpoint()
        fileUploadListModel.addUpload(
            with: data,
            format: format
        )
    }

    private func determineFileUploadEndpoint() {
        let isEngagementOngoing = environment.getCurrentEngagement() != nil
        fileUploadListModel.environment.uploader.environment.uploadFile =
        isEngagementOngoing ?
            .toEngagement(environment.uploadFileToEngagement) :
            .toSecureMessaging(environment.uploadSecureFile)
    }

    private func removeUpload(_ upload: FileUpload) {
        fileUploadListModel.removeUpload(upload)
    }
}

extension SecureConversations.WelcomeViewModel: Hashable {
    static func == (lhs: SecureConversations.WelcomeViewModel, rhs: SecureConversations.WelcomeViewModel) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
