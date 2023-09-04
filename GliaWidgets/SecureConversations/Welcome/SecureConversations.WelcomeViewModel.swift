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

        static let sendMessageErrorAlertAccIdentifier = "send_message_alert_error_identifier"
        static let unavailableMessageCenterAlertAccIdentidier = "unavailable_message_center_alert_identifier"

        static let messageTextLimit = 10_000
        static let maximumUploads = 25

        var action: ((Action) -> Void)?
        var delegate: ((DelegateEvent) -> Void)?
        var environment: Environment
        var availability: Availability

        var messageText: String = "" { didSet { reportChange() } }
        /// Flag indicating attachment(s) availability.
        /// By default attachments are not available, until site configurations are fetched.
        private (set) var isAttachmentsAvailable: Bool = false { didSet { reportChange() } }
        var availabilityStatus: Availability.Status = .available { didSet { reportChange() } }
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
            availability.checkSecureConversationsAvailability { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(.available):
                    self.availabilityStatus = .available
                case .success(.unavailable(.emptyQueue)), .failure:
                    self.availabilityStatus = .unavailable(.emptyQueue)
                    let configuration = self.environment.alertConfiguration.unavailableMessageCenter
                    self.delegate?(
                        .showAlertAsView(
                            configuration,
                            accessibilityIdentifier: Self.unavailableMessageCenterAlertAccIdentidier,
                            dismissed: nil
                        )
                    )
                case .success(.unavailable(.unauthenticated)):
                    self.availabilityStatus = .unavailable(.unauthenticated)
                    let configuration = self.environment.alertConfiguration.unavailableMessageCenterForBeingUnauthenticated
                    self.delegate?(
                        .showAlertAsView(
                            configuration,
                            accessibilityIdentifier: Self.unavailableMessageCenterAlertAccIdentidier,
                            dismissed: nil
                        )
                    )
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
        ) { [weak self, alertConfiguration = environment.alertConfiguration] result in
            self?.sendMessageRequestState = .waiting

            switch result {
            case .success:
                self?.delegate?(.confirmationScreenRequested)
            case .failure:
                self?.delegate?(
                    .showAlert(
                        alertConfiguration.unexpectedError,
                        accessibilityIdentifier: Self.sendMessageErrorAlertAccIdentifier,
                        dismissed: nil
                    )
                )
            }
        }
    }
    func loadAttachmentAvailability() {
        environment.fetchSiteConfigurations { [weak self, alertConfiguration = environment.alertConfiguration] result in
            switch result {
            case let .success(site):
                self?.isAttachmentsAvailable = site.allowedFileSenders.visitor
            case .failure:
                self?.delegate?(
                    .showAlert(
                        alertConfiguration.unexpectedError,
                        accessibilityIdentifier: Self.sendMessageErrorAlertAccIdentifier,
                        dismissed: nil
                    )
                )
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

        if instance.availabilityStatus != .available {
            style.messageTitleStyle = nil
        }

        return style
    }

    static func filePickerButtonState(
        for instance: SecureConversations.WelcomeViewModel
    ) -> WelcomeViewProps.FilePickerButton? {
        var filePickerButton: WelcomeViewProps.FilePickerButton?

        let isFilePickerEnabled = !instance.fileUploadListModel.isLimitReached
        if instance.availabilityStatus == .available && instance.isAttachmentsAvailable {
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
        guard instance.availabilityStatus == .available else {
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
        guard instance.availabilityStatus == .available else {
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
        case showAlert(
            MessageAlertConfiguration,
            accessibilityIdentifier: String?,
            dismissed: (() -> Void)?
        )
        case showAlertAsView(
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
        var sendSecureMessagePayload: CoreSdkClient.SendSecureMessagePayload
        var alertConfiguration: AlertConfiguration
        var fileUploader: FileUploader
        var uiApplication: UIKitBased.UIApplication
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var startSocketObservation: CoreSdkClient.StartSocketObservation
        var stopSocketObservation: CoreSdkClient.StopSocketObservation
        var getCurrentEngagement: CoreSdkClient.GetCurrentEngagement
        var uploadSecureFile: CoreSdkClient.SecureConversationsUploadFile
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var createSendMessagePayload: CoreSdkClient.CreateSendMessagePayload
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
        delegate?(
            .showAlert(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
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
