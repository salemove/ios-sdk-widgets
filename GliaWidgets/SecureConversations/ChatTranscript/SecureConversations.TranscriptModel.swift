import Foundation

extension SecureConversations {
    final class TranscriptModel: CommonEngagementModel {
        typealias ActionCallback = (Action) -> Void
        typealias DelegateCallback = (DelegateEvent) -> Void
        typealias Action = ChatViewModel.Action

        enum DelegateEvent {
            case showFile(LocalFile)
            case pickMedia(ObservableValue<MediaPickerEvent>)
            case takeMedia(ObservableValue<MediaPickerEvent>)
            case pickFile(ObservableValue<FilePickerEvent>)
            case upgradeToChatEngagement(TranscriptModel)
            case minimize
        }

        typealias Event = ChatViewModel.Event

        static let messageTextLimit = WelcomeViewModel.messageTextLimit

        var action: ActionCallback?
        var delegate: DelegateCallback?
        var engagementAction: EngagementViewModel.ActionCallback?
        var engagementDelegate: EngagementViewModel.DelegateCallback?

        /// Used to check whether custom card contains interactable metadata.
        var isInteractableCard: ((MessageRenderer.Message) -> Bool)?
        /// Used to check whether custom card should be hidden.
        var shouldShowCard: ((MessageRenderer.Message) -> Bool)?

        var isChoiceCardInputModeEnabled: Bool = false

        private let downloader: FileDownloader
        let fileUploadListModel: SecureConversations.FileUploadListViewModel
        private(set) var hasViewAppeared: Bool
        private(set) var messageText = "" {
            didSet {
                validateMessage()
                action?(.setMessageText(messageText))
            }
        }

        private let isCustomCardSupported: Bool
        private let isChatScrolledToBottom = ObservableValue<Bool>(with: true)
        private(set) var isViewLoaded: Bool = false

        var environment: Environment
        var availability: Availability
        var interactor: Interactor
        var entryWidget: EntryWidget?

        private(set) var isSecureConversationsAvailable: Bool = true {
            didSet {
                action?(.transcript(.messageCenterAvailabilityUpdated))
            }
        }

        var siteConfiguration: CoreSdkClient.Site?

        var mediaPickerButtonEnabling: MediaPickerButtonEnabling {
            guard let site = siteConfiguration else { return .disabled }
            guard site.allowedFileSenders.visitor else { return .disabled }
            return .enabled(.secureMessaging)
        }

        var sections = [
            Section<ChatItem>(0),
            Section<ChatItem>(1),
            Section<ChatItem>(2),
            Section<ChatItem>(3)
        ]

        var historySection: Section<ChatItem> { sections[0] }
        var pendingSection: Section<ChatItem> { sections[1] }

        private(set) var receivedMessages = [String: [MessageSource]]()

        private let deliveredStatusText: String
        private let failedToDeliverStatusText: String
        private(set) var hasUnreadMessages = false

        var numberOfSections: Int {
            sections.count
        }

        let transcriptMessageLoader: SecureConversations.MessagesWithUnreadCountLoader

        private var markMessagesAsReadCancellables = CancelBag()

        init(
            isCustomCardSupported: Bool,
            environment: Environment,
            availability: Availability,
            deliveredStatusText: String,
            failedToDeliverStatusText: String,
            interactor: Interactor
        ) {
            self.isCustomCardSupported = isCustomCardSupported
            self.environment = environment
            self.downloader = FileDownloader(environment: .create(with: environment))
            self.availability = availability
            self.deliveredStatusText = deliveredStatusText
            self.failedToDeliverStatusText = failedToDeliverStatusText
            self.interactor = interactor
            self.hasViewAppeared = false
            let uploader = FileUploader(
                maximumUploads: environment.maximumUploads(),
                environment: .create(with: environment)
            )

            self.fileUploadListModel = environment.createFileUploadListModel(
                .init(
                    uploader: uploader,
                    style: .chat(environment.fileUploadListStyle),
                    scrollingBehaviour: .scrolling(environment.uiApplication)
                )
            )

            self.transcriptMessageLoader = .init(environment: .create(with: environment))
            do {
                self.entryWidget = try environment.createEntryWidget(makeEntryWidgetConfiguration())
            } catch {
                // Creating an entry widget may fail if the SDK is not configured.
                // This assumes that the SDK is configured by accessing Secure Conversations.
                environment.log.warning("Could not create EntryWidget on Secure Conversation")
            }

            self.fileUploadListModel.delegate = { [weak self] event in
                switch event {
                case let .renderProps(uploadListViewProps):
                    self?.action?(.fileUploadListPropsUpdated(uploadListViewProps))
                    // Validate ability to send message, to cover cases where
                    // sending is not possible because of file upload limitations.
                    self?.validateMessage()
                }
            }

            uploader.limitReached.addObserver(self) { [weak self] limitReached, _ in
                self?.action?(.pickMediaButtonEnabled(!limitReached))
            }
            checkSecureConversationsAvailability()
        }

        private func checkSecureConversationsAvailability() {
            availability.checkSecureConversationsAvailability(for: environment.queueIds) { [weak self] result in
                guard let self else { return }
                switch result {
                case let .success(.available(.queues(queueIds))):
                    self.environment.queueIds = queueIds
                    self.isSecureConversationsAvailable = true
                    self.fileUploadListModel.isEnabled = true
                case .success(.available(.transferred)):
                    self.environment.queueIds = []
                    self.isSecureConversationsAvailable = true
                    self.fileUploadListModel.isEnabled = true
                case .failure, .success(.unavailable(.emptyQueue)), .success(.unavailable(.unauthenticated)):
                    // For chat screen we no longer show unavailability dialog, but unavailability banner instead.
                    self.isSecureConversationsAvailable = false
                    self.fileUploadListModel.isEnabled = false
                }
            }
        }

        func numberOfItems(in section: Int) -> Int {
            sections[section].itemCount
        }

        func item(for row: Int, in section: Int) -> ChatItem {
            SecureConversations.ChatWithTranscriptModel
                .item(
                    for: row,
                    in: section,
                    from: sections,
                    downloader: downloader
                )
        }

        private func shouldShowOperatorImage(
            for row: Int,
            in section: Section<ChatItem>
        ) -> Bool {
            guard section[row].isOperatorMessage else { return false }
            let nextItem = section.item(after: row)
            return nextItem == nil || nextItem?.isOperatorMessage == false
        }

        func event(_ event: EngagementViewModel.Event) {
            switch event {
            case .closeTapped:
                engagementDelegate?(.finished)
            default: break
            }
        }

        func event(_ event: Event) {
            switch event {
            case .viewDidLoad:
                isViewLoaded = true
            case .messageTextChanged(let text):
                messageText = text
            case .sendTapped:
                sendMessage()
            case .removeUploadTapped(let upload):
                removeUpload(upload)
            case .pickMediaTapped:
                presentMediaPicker()
            case .callBubbleTapped:
                // Not supported for transcript.
                break
            case .fileTapped(let file):
                fileTapped(file)
            case .downloadTapped(let download):
                downloadTapped(download)
            case .choiceOptionSelected:
                // Not supported for transcript.
                break
            case .chatScrolled(let bottomReached):
                isChatScrolledToBottom.value = bottomReached
            case .linkTapped(let url):
                linkTapped(url)
            case .customCardOptionSelected:
                // Not supported for transcript.
                break
            case let .gvaButtonTapped(option):
                gvaOptionAction(for: option)()
            case let .retryMessageTapped(message):
                retryMessageSending(message)
            }
        }

        /// Starts socket observation, fetches site configuration and loads chat history if needed.
        /// - Parameter isTranscriptFetchNeeded: A flag indicating whether chat history will be loaded.
        func start(isTranscriptFetchNeeded: Bool) {
            environment.startSocketObservation()
            fetchSiteConfigurations()

            guard isTranscriptFetchNeeded else {
                return
            }

            loadHistory { [weak self] _ in
                self?.showLeaveConversationDialogIfNeeded()
            }
        }

        deinit {
            environment.interactor.removeObserver(self)
        }
    }
}

// MARK: Input validation
extension SecureConversations.TranscriptModel {
    @discardableResult
    func validateMessage() -> Bool {
        let canSendAttachments =
        fileUploadListModel.failedUploads.isEmpty &&
        fileUploadListModel.activeUploads.isEmpty && !fileUploadListModel.isLimitReached

        guard canSendAttachments else { return false }

        let canSendText = !messageText.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty && messageText.count <= Self.messageTextLimit
        let hasAttachments = !fileUploadListModel.succeededUploads.isEmpty

        let isValid = canSendText || hasAttachments
        action?(.sendButtonDisabled(!isValid))
        return isValid
    }
}

// MARK: Message management
extension SecureConversations.TranscriptModel {
    func sendMessage() {
        guard validateMessage() else { return }

        let uploads = fileUploadListModel.succeededUploads
        let localFiles = uploads.map(\.localFile)

        let payload = environment.createSendMessagePayload(
            messageText,
            fileUploadListModel.attachment
        )

        let outgoingMessage = OutgoingMessage(
            payload: payload,
            files: localFiles
        )

        appendItem(
            .init(kind: .outgoingMessage(outgoingMessage, error: nil)),
            to: pendingSection,
            animated: true
        )

        _ = environment.sendSecureMessagePayload(
            outgoingMessage.payload,
            environment.queueIds
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(message):
                self.receiveMessage(from: .api(message, outgoingMessage: outgoingMessage))
            case .failure:
                self.markMessageAsFailed(
                    outgoingMessage,
                    in: self.pendingSection
                )
            }
        }

        // Clear inputs, thus disabling them
        // and preventing the message to be sent again.
        clearInputs()
        action?(.scrollToBottom(animated: true))
    }

    func replace(
        _ outgoingMessage: OutgoingMessage,
        uploads: [FileUpload],
        with message: CoreSdkClient.Message,
        in section: Section<ChatItem>
    ) {
        SecureConversations.ChatWithTranscriptModel
            .replace(
                outgoingMessage,
                uploads: uploads,
                with: message,
                in: section,
                deliveredStatusText: deliveredStatusText,
                downloader: downloader,
                action: action
            )
    }

    func clearInputs() {
        messageText = ""
        fileUploadListModel.removeSucceededUploads()
    }
}

// MARK: Message sending retry
extension SecureConversations.TranscriptModel {
    private func retryMessageSending(_ outgoingMessage: OutgoingMessage) {
        removeMessage(
            outgoingMessage,
            in: pendingSection
        )

        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: pendingSection, animated: true)
        action?(.scrollToBottom(animated: true))

        _ = environment.sendSecureMessagePayload(
            outgoingMessage.payload,
            environment.queueIds
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(message):
                self.receiveMessage(from: .api(message, outgoingMessage: outgoingMessage))
            case .failure:
                self.markMessageAsFailed(
                    outgoingMessage,
                    in: self.pendingSection
                )
            }
        }
    }
}

// MARK: Section management
extension SecureConversations.TranscriptModel {
    func appendItem(
        _ item: ChatItem,
        to section: Section<ChatItem>,
        animated: Bool
    ) {
        appendItems(
            [item],
            to: section,
            animated: animated
        )
    }

    private func appendItems(
        _ items: [ChatItem],
        to section: Section<ChatItem>,
        animated: Bool
    ) {
        section.append(items)
        action?(.appendRows(
            items.count,
            to: section.index,
            animated: animated
        ))
    }
}

// MARK: Interaction with messages
extension SecureConversations.TranscriptModel {
    private func fileTapped(_ file: LocalFile) {
        delegate?(.showFile(file))
    }

    private func downloadTapped(_ download: FileDownload) {
        switch download.state.value {
        case .none:
            download.startDownload()
        case .downloading:
            break
        case .downloaded(let file):
            delegate?(.showFile(file))
        case .error:
            download.startDownload()
        }
    }

    func linkTapped(_ url: URL) {
        guard environment.uiApplication.canOpenURL(url) else {
            environment.log.prefixed(Self.self).error("No dialer uri - \(url)")
            return
        }
        environment.uiApplication.open(url)
    }

    func markMessageAsFailed(
        _ outgoingMessage: OutgoingMessage,
        in section: Section<ChatItem>
    ) {
        SecureConversations.ChatWithTranscriptModel.markMessageAsFailed(
            outgoingMessage,
            in: section,
            message: failedToDeliverStatusText,
            action: action
        )
    }

    func removeMessage(
        _ outgoingMessage: OutgoingMessage,
        in section: Section<ChatItem>
    ) {
        SecureConversations.ChatWithTranscriptModel.removeMessage(
            outgoingMessage,
            in: section,
            action: action
        )
    }
}

// MARK: Handling of file-picker
extension SecureConversations.TranscriptModel {
    private func presentMediaPicker() {
        let itemSelected = { [weak self] (kind: AttachmentSourceItemKind) in
            let media = ObservableValue<MediaPickerEvent>(with: .none)
            guard let self = self else { return }
            media.addObserver(self) { [weak self] event, _ in
                guard let self = self else { return }
                switch event {
                case .none, .cancelled:
                    break
                case .pickedMedia(let media):
                    self.mediaPicked(media)
                case .sourceNotAvailable:
                    self.engagementAction?(.showAlert(.mediaSourceNotAvailable()))
                case .noCameraPermission:
                    self.engagementAction?(.showAlert(.cameraSettings()))
                }
            }
            let file = ObservableValue<FilePickerEvent>(with: .none)
            file.addObserver(self) { [weak self] event, _ in
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
        action?(.presentMediaPicker(itemSelected: { itemSelected($0) }))
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

    private func filePicked(_ url: URL) {
        addUpload(with: url)
    }
}

// MARK: File Upload
extension SecureConversations.TranscriptModel {
    private func addUpload(with url: URL) {
        guard let upload = fileUploadListModel.addUpload(with: url) else { return }
        action?(.addUpload(upload))
    }

    private func addUpload(with data: Data, format: MediaFormat) {
        guard let upload = fileUploadListModel.addUpload(with: data, format: format) else { return }
        action?(.addUpload(upload))
    }

    private func removeUpload(_ upload: FileUpload) {
        fileUploadListModel.removeUpload(upload)
        action?(.removeUpload(upload))
        validateMessage()
    }

    private func onUploaderStateChanged(_ state: FileUploader.State) {
        validateMessage()
    }
}

// MARK: Site Confgurations
extension SecureConversations.TranscriptModel {
    func fetchSiteConfigurations() {
        environment.fetchSiteConfigurations { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let site):
                self.siteConfiguration = site
                self.action?(.setAttachmentButtonEnabling(self.mediaPickerButtonEnabling))
            case let .failure(error):
                self.engagementAction?(.showAlert(.error(error: error)))
            }
        }
    }
}

// MARK: History
extension SecureConversations.TranscriptModel {
    private func loadHistory(_ completion: @escaping ([ChatMessage]) -> Void) {
        transcriptMessageLoader.loadMessagesWithUnreadCount { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(messagesWithUnreadCount):
                let items: [ChatItem] = messagesWithUnreadCount.messages.compactMap {
                    ChatItem(
                        with: $0,
                        isCustomCardSupported: self.isCustomCardSupported,
                        fromHistory: self.environment.loadChatMessagesFromHistory()
                    )
                }

                let itemsWithDivider = Self.dividedChatItemsForUnreadCount(
                    chatItems: items,
                    unreadCount: messagesWithUnreadCount.unreadCount,
                    divider: ChatItem(kind: .unreadMessageDivider)
                )

                self.hasUnreadMessages = messagesWithUnreadCount.unreadCount > 0
                self.historySection.set(itemsWithDivider)
                self.action?(.refreshSection(self.historySection.index))
                self.action?(.scrollToBottom(animated: false))
                completion(messagesWithUnreadCount.messages)
                markMessagesAsRead(
                    with: self.hasUnreadMessages && !environment.shouldShowLeaveSecureConversationDialog
                )

                if let item = items.last, case .gvaQuickReply(_, let button, _, _) = item.kind {
                    let props = button.options.compactMap { [weak self] in self?.quickReplyOption($0) }
                    self.action?(.quickReplyPropsUpdated(.shown(props)))
                }
            case .failure:
                completion([])
            }
        }
    }

    func handleInteractorEvent(_ event: InteractorEvent) {
        switch event {
        case .stateChanged(.engaged):
            // We no longer need to listen to Interactor events,
            // so unsubscribe.
            self.environment.interactor.removeObserver(self)
            delegate?(.upgradeToChatEngagement(self))
        case let .receivedMessage(message):
            receiveMessage(from: .socket(message))
            markMessagesAsRead(with: message.sender.type != .visitor)
        default:
            break
        }
    }

    /// Wraps message to determine how to replace it when it is delivered.
    enum MessageSource: Identifiying, Equatable {
        case api(CoreSdkClient.Message, outgoingMessage: OutgoingMessage)
        case socket(CoreSdkClient.Message)

        var id: String {
            message.id
        }

        var message: CoreSdkClient.Message {
            switch self {
            case let .api(message, _):
                return message
            case let .socket(message):
                return message
            }
        }

        var outgoingMessage: OutgoingMessage? {
            switch self {
            case let .api(_, outgoingMessage):
                return outgoingMessage
            case  .socket:
                return nil
            }
        }
    }

    func receiveMessage(from messageSource: MessageSource) {
        var list = receivedMessages[messageSource.id] ?? []

        // If list is empty, it means that the message hasn't been received through web sockets yet.
        // Thus we need to render it and save it. Otherwise, we should replace it. This is done to
        // avoid rendering duplicated messages.
        if list.isEmpty {
            switch messageSource.message.sender.type {
            case .system:
                let message = ChatMessage(with: messageSource.message)

                if let item = ChatItem(
                    with: message,
                    isCustomCardSupported: false,
                    fromHistory: false
                ) {
                    guard isViewLoaded else { return }

                    let isChatBottomReached = isChatScrolledToBottom.value
                    appendItem(item, to: pendingSection, animated: true)
                    action?(.updateItemsUserImage(animated: true))

                    if isChatBottomReached {
                        action?(.scrollToBottom(animated: true))
                    }

                    list.append(messageSource)
                    receivedMessages[messageSource.id] = list
                }
            case .operator:
                let message = ChatMessage(
                    with: messageSource.message,
                    operator: interactor.engagedOperator
                )

                if let item = ChatItem(
                    with: message,
                    isCustomCardSupported: isCustomCardSupported,
                    fromHistory: false
                ) {
                    guard isViewLoaded else { return }

                    let isChatBottomReached = isChatScrolledToBottom.value

                    appendItem(item, to: pendingSection, animated: true)
                    action?(.updateItemsUserImage(animated: true))

                    let choiceCardInputModeEnabled = message.cardType == .choiceCard || self.isInteractableCustomCard(message)
                    action?(.setChoiceCardInputModeEnabled(choiceCardInputModeEnabled))

                    // Store info about choice card mode from which
                    // attachment button visibility will be calculated.
                    self.isChoiceCardInputModeEnabled = choiceCardInputModeEnabled

                    if isChatBottomReached {
                        action?(.scrollToBottom(animated: true))
                    }
                }
            default: break
            }
        } else {
            // We store message and try to determine if
            // it has attachment. This depends on origin
            // from which message was received. REST API
            // does not return information about attachments,
            // so we use messages delivered from socket instead.
            list.append(messageSource)
            receivedMessages[messageSource.id] = list
            let withPossibleAttachment = list.last(where: { $0.message.attachment != nil })?.message ?? messageSource.message
            // We try to reuse outgoing message to show `delivered` status
            // to indicated that message is delivered.
            let outgoingMessage = list.last(where: { $0.outgoingMessage != nil })?.outgoingMessage ??
                OutgoingMessage(
                    payload: self.environment.createSendMessagePayload(messageSource.message.content, nil),
                    files: fileUploadListModel.succeededUploads.map(\.localFile)
                )
            self.replace(
                outgoingMessage,
                uploads: fileUploadListModel.succeededUploads,
                with: withPossibleAttachment,
                in: self.pendingSection
            )
        }
    }
}

// MARK: Entry Widget
extension SecureConversations.TranscriptModel {
    // Set up the Entry Widget configuration inside TranscriptModel,
    // since it requires passing view model logic to the configuration.
    private func makeEntryWidgetConfiguration() -> EntryWidget.Configuration {
        .init(
            sizeConstraints: .init(
                singleCellHeight: 56,
                singleCellIconSize: 24,
                poweredByContainerHeight: 40,
                sheetHeaderHeight: 36,
                sheetHeaderDraggerWidth: 32,
                sheetHeaderDraggerHeight: 4,
                dividerHeight: 1,
                dividerHorizontalPadding: 0
            ),
            showPoweredBy: false,
            filterSecureConversation: true,
            mediaTypeSelected: .init { [weak self] mediaType in
                self?.entryWidgetMediaTypeSelected(mediaType)
            },
            mediaTypeItemsStyle: environment.topBannerItemsStyle
        )
    }

    private func entryWidgetMediaTypeSelected(_ item: EntryWidget.MediaTypeItem) {
        action?(.switchToEngagement)
        engagementAction?(.showAlert(.leaveCurrentConversation { [weak self] in
            let kind: EngagementKind
            switch item.type {
            case .video:
                kind = .videoCall
            case .audio:
                kind = .audioCall
            case .chat:
                kind = .chat
            case .secureMessaging:
                kind = .messaging(.welcome)
            case .callVisualizer:
                return
            }
            self?.environment.switchToEngagement(kind)
        }))
    }
}

// MARK: Mark messages as read
extension SecureConversations.TranscriptModel: ApplicationVisibilityTracker {
    // The method is used to mark messages as read with delay
    // when the app is visible or becomes visible.
    // - Parameters:
    //   - predicate: A boolean value that determines whether messages should be marked as read.
    func markMessagesAsRead(with predicate: Bool = true) {
        guard predicate else {
            return
        }
        markMessagesAsReadCancellables.removeAll()
        isAppVisiblePublisher(
            for: environment.uiApplication.applicationState(),
            notificationCenter: environment.notificationCenter,
            resumeToForegroundDelay: environment.markUnreadMessagesDelay(),
            delayScheduler: environment.combineScheduler.global()
        )
            .sink { [weak self] _ in
                self?.performMarkMessagesAsReadRequest()
            }
            .store(in: &markMessagesAsReadCancellables)
    }

    fileprivate func performMarkMessagesAsReadRequest() {
        _ = environment.secureMarkMessagesAsRead { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                historySection.removeAll(where: {
                    if case .unreadMessageDivider = $0.kind {
                        return true
                    }

                    return false
                })

                action?(.refreshSection(self.historySection.index, animated: true))

                if isChatScrolledToBottom.value {
                    action?(.scrollToBottom(animated: true))
                }
            case .failure:
                break
            }
        }
    }
}

#if DEBUG
extension SecureConversations.TranscriptModel {
    /// Setter for `isSecureConversationsAvailable`. Used in unit tests.
    func setIsSecureConversationsAvailable(_ available: Bool) {
        self.isSecureConversationsAvailable = available
    }

    static func mock(
        isCustomCardSupported: Bool = false,
        environment: Environment = .mock(),
        availability: SecureConversations.Availability,
        deliveredStatusText: String,
        failedToDeliverStatusText: String,
        interactor: Interactor
    ) -> SecureConversations.TranscriptModel {
        .init(
            isCustomCardSupported: isCustomCardSupported,
            environment: environment,
            availability: availability,
            deliveredStatusText: deliveredStatusText,
            failedToDeliverStatusText: failedToDeliverStatusText,
            interactor: interactor
        )
    }
}
#endif
// MARK: View Appeared
extension SecureConversations.TranscriptModel {
    func setViewAppeared() {
        hasViewAppeared = true
    }
}

extension SecureConversations.TranscriptModel {
    func migrate(
        from chatModel: ChatViewModel
    ) {
        clearSections(sections)
        // Filter out items that are not reflected in transcript
        let items = chatModel.sections.flatMap(\.items).filter {
            switch $0.kind {
            case .callUpgrade,
                    .operatorConnected,
                    .queueOperator,
                    .transferring,
                    .unreadMessageDivider:
                return false
            case .outgoingMessage,
                    .visitorMessage,
                    .choiceCard,
                    .customCard,
                    .gvaGallery,
                    .gvaPersistentButton,
                    .gvaQuickReply,
                    .gvaResponseText,
                    .operatorMessage,
                    .systemMessage:
                return true
            }
        }
        historySection.set(items)
        action?(.refreshAll)

        // There's a possibility where migration to SC (this actually doesn't seem to work ATM, needs checking (MOB-3988)).
        // happens when there are awaiting uploads.
        // For that case we need to make sure that theses uploads
        // have also migrated to use engagement based API.
        fileUploadListModel.environment.uploader.uploads = chatModel
            .fileUploadListModel
            .environment
            .uploader
            .uploads
            .map { [environment] upload in
                upload.environment.uploadFile = .toSecureMessaging(environment.secureUploadFile)
                return upload
            }
        event(.messageTextChanged(chatModel.messageText))
        // Since we have modified file upload list view model,
        // we need to report about this change manually
        // to keep UI in sync with data.
        fileUploadListModel.reportChange()
        isViewLoaded = chatModel.isViewLoaded
        action?(.scrollToBottom(animated: true))
        // Return chat message entry to `isConnected = false`
        // to display corresponding placeholder.
        action?(.setMessageEntryConnected(false))
        engagementAction?(.showCloseButton)
        // Since we only need to start socket observation,
        // we skip chat transcript loading.
        start(isTranscriptFetchNeeded: false)
    }

    func clearSections(_ sections: [Section<ChatItem>]) {
        sections.forEach { $0.set([]) }
    }
}
