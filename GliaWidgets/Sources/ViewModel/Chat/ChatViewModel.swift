import Foundation

class ChatViewModel: EngagementViewModel {
    typealias ActionCallback = (Action) -> Void
    typealias DelegateCallback = (DelegateEvent) -> Void

    var action: ActionCallback?
    var delegate: DelegateCallback?
    // Used to check whether custom card contains interactable metadata.
    var isInteractableCard: ((MessageRenderer.Message) -> Bool)?
    // Used to check whether custom card should be hidden.
    var shouldShowCard: ((MessageRenderer.Message) -> Bool)?

    private let startAction: StartAction
    var sections = [
        Section<ChatItem>(0),
        Section<ChatItem>(1),
        Section<ChatItem>(2),
        Section<ChatItem>(3)
    ]
    var historySection: Section<ChatItem> { sections[0] }
    var pendingSection: Section<ChatItem> { sections[1] }
    var queueOperatorSection: Section<ChatItem> { sections[2] }
    var messagesSection: Section<ChatItem> { sections[3] }

    private let call: ObservableValue<Call?>
    private var unreadMessages: UnreadMessagesHandler!
    private let isChatScrolledToBottom = ObservableValue<Bool>(with: true)
    private let showsCallBubble: Bool
    let isCustomCardSupported: Bool
    let fileUploadListModel: SecureConversations.FileUploadListViewModel

    private let downloader: FileDownloader
    private let deliveredStatusText: String
    private let failedToDeliverStatusText: String
    private(set) var messageText = "" {
        didSet {
            validateMessage()
            sendMessagePreview(messageText)
            action?(.setMessageText(messageText))
        }
    }

    private var pendingMessages: [OutgoingMessage] = []
    var isViewLoaded: Bool = false
    var isChoiceCardInputModeEnabled: Bool = false
    private(set) var siteConfiguration: CoreSdkClient.Site?
    // Stored message ids retrieved from history.
    // They are used to discard messages received from socket
    // to avoid duplication.
    private(set) var historyMessageIds: Set<ChatMessage.MessageId> = []
    private(set) var receivedMessageIds: Set<ChatMessage.MessageId> = []

    var mediaPickerButtonEnabling: MediaPickerButtonEnabling {
        guard let site = siteConfiguration else { return .disabled }
        guard site.allowedFileSenders.visitor else { return .disabled }
        guard environment.getCurrentEngagement() != nil else {
            return .enabled(.engagementConnection(isConnected: false))
        }
        return .enabled(.engagementConnection(isConnected: environment.getCurrentEngagement() != nil))
    }

    private(set) var chatType: ChatType

    init(
        interactor: Interactor,
        screenShareHandler: ScreenShareHandler,
        call: ObservableValue<Call?>,
        unreadMessages: ObservableValue<Int>,
        showsCallBubble: Bool,
        isCustomCardSupported: Bool,
        isWindowVisible: ObservableValue<Bool>,
        startAction: StartAction,
        deliveredStatusText: String,
        failedToDeliverStatusText: String,
        chatType: ChatType,
        environment: Environment,
        maximumUploads: () -> Int
    ) {
        self.call = call
        self.showsCallBubble = showsCallBubble
        self.isCustomCardSupported = isCustomCardSupported
        self.startAction = startAction
        self.chatType = chatType
        let uploader = FileUploader(
            maximumUploads: maximumUploads(),
            environment: .create(with: environment)
        )
        self.fileUploadListModel = environment.createFileUploadListModel(
            .init(
                uploader: uploader,
                style: .chat(environment.fileUploadListStyle),
                scrollingBehaviour: .scrolling(environment.uiApplication)
            )
        )

        defer {
            self.fileUploadListModel.delegate = { [weak self] event in
                switch event {
                case let .renderProps(uploadListViewProps):
                    self?.action?(.fileUploadListPropsUpdated(uploadListViewProps))
                    // Validate ability to send message, to cover cases where
                    // sending is not possible because of file upload limitations.
                    self?.validateMessage()
                }
            }
        }

        self.downloader = FileDownloader(environment: .create(with: environment))
        self.deliveredStatusText = deliveredStatusText
        self.failedToDeliverStatusText = failedToDeliverStatusText
        super.init(
            interactor: interactor,
            screenShareHandler: screenShareHandler,
            environment: environment
        )
        unreadMessages.addObserver(self) { [weak self] unreadCount, _ in
            self?.action?(.updateUnreadMessageIndicator(itemCount: unreadCount))
        }
        self.unreadMessages = UnreadMessagesHandler(
            unreadMessages: unreadMessages,
            isWindowVisible: isWindowVisible,
            isViewVisible: isViewActive,
            isChatScrolledToBottom: isChatScrolledToBottom
        )
        self.call.addObserver(self) { [weak self] call, _ in
            self?.onCall(call)
        }
        uploader.state.addObserver(self) { [weak self] state, _ in
            self?.onUploaderStateChanged(state)
        }
        uploader.limitReached.addObserver(self) { [weak self] limitReached, _ in
            self?.action?(.pickMediaButtonEnabled(!limitReached))
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if showsCallBubble {
            showCallBubble()
        }
    }

    override func start() {
        super.start()

        loadHistory { [weak self] history in
            guard let self = self else { return }
            // We only proceed to considering enqueue flow if `startAction` is about starting of engagement.
            guard case .startEngagement = self.startAction else { return }
            // We enqueue eagerly in case if this is the first engagement for visitor (by  evaluating previous chat history)
            // or in case if engagement has been restored.

            if history.isEmpty || self.environment.getNonTransferredSecureConversationEngagement() != nil {
                self.interactor.state = .enqueueing(.chat)
            }
        }
    }

    override func update(for state: InteractorState) {
        super.update(for: state)

        switch state {
        case .enqueueing:
            guard !Self.shouldSkipEnqueueingState(for: chatType) else { return }
            let item = ChatItem(kind: .queueOperator)

            appendItem(
                item,
                to: queueOperatorSection,
                animated: false
            )

            action?(.queue)
            action?(.scrollToBottom(animated: true))
        case .engaged(let engagedOperator):
            environment.log.prefixed(Self.self).info("Operator connected")
            let name = engagedOperator?.firstName
            let pictureUrl = engagedOperator?.picture?.url
            let chatItem = ChatItem(kind: .operatorConnected(name: name, imageUrl: pictureUrl))

            setItems([], to: queueOperatorSection)
            appendItem(
                chatItem,
                to: messagesSection,
                animated: false
            )

            action?(.connected(name: name, imageUrl: pictureUrl))
            action?(.scrollToBottom(animated: false))
            action?(.setMessageEntryEnabled(true))

            handleScreenSharingStatus(screenShareHandler.status().value)

            fetchSiteConfigurations()

            pendingMessages.forEach { [weak self] outgoingMessage in
                self?.interactor.send(messagePayload: outgoingMessage.payload) {  [weak self] result in
                    guard let self else { return }
                    switch result {
                    case let .success(message):
                        // When pending message is successfully delivered,
                        // it has to be removed from the `pendingMessages` list, to avoid
                        // situation where it gets sent again, for example after
                        // transfer to another operator.
                        removePendingMessage(by: message.id)
                        self.replace(
                            outgoingMessage,
                            uploads: [],
                            with: message,
                            in: self.messagesSection
                        )

                        self.action?(.scrollToBottom(animated: true))
                    case .failure:
                        self.markMessageAsFailed(
                            outgoingMessage,
                            in: self.messagesSection
                        )
                    }
                }
            }
        default:
            break
        }
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .receivedMessage(let message):
            receivedMessage(message)
        case .messagesUpdated(let messages):
            messagesUpdated(messages)
        case .upgradeOffer(let offer, answer: let answer):
            offerMediaUpgrade(offer, answer: answer)
        case .typingStatusUpdated(let status):
            typingStatusUpdated(status)
        case .engagementTransferring:
            onEngagementTransferring()
        case .onLiveToSecureConversationsEngagementTransferring:
            setChatType(.secureTranscript(upgradedFromChat: true))
            handleScreenSharingStatus(screenShareHandler.status().value)
            action?(.refreshAll)
        case .engagementTransferred:
            onEngagementTransferred()
        case let .stateChanged(state):
            handleInteractorStateChanged(state)
        default:
            break
        }
    }
}

extension ChatViewModel {
    func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
            isViewLoaded = true
        case .messageTextChanged(let text):
            messageText = text
        case .sendTapped:
            sendMessage()
            action?(.quickReplyPropsUpdated(.hidden))
        case .removeUploadTapped(let upload):
            removeUpload(upload)
        case .pickMediaTapped:
            presentMediaPicker()
        case .callBubbleTapped:
            delegate?(.call)
        case .fileTapped(let file):
            fileTapped(file)
        case .downloadTapped(let download):
            downloadTapped(download)
        case .choiceOptionSelected(let option, let messageId):
            sendChoiceCardResponse(option, to: messageId)
        case .chatScrolled(let bottomReached):
            isChatScrolledToBottom.value = bottomReached
        case .linkTapped(let url):
            linkTapped(url)
        case .customCardOptionSelected(let option, let messageId):
            sendSelectedCustomCardOption(option, for: messageId)
        case .gvaButtonTapped(let option):
            gvaOptionAction(for: option)()
        case .retryMessageTapped(let message):
            retryMessageSending(message)
        }
    }

    func setChatType(_ chatType: ChatType) {
        self.chatType = chatType
    }
}

extension ChatViewModel {
    private func onEngagementTransferring() {
        action?(.setMessageEntryEnabled(false))
        action?(.setAttachmentButtonEnabling(.disabled))
        appendItem(.init(kind: .transferring), to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))
        endScreenSharing()
    }

    private func onEngagementTransferred() {
        action?(.setMessageEntryEnabled(true))
        action?(.setAttachmentButtonEnabling(mediaPickerButtonEnabling))

        let engagedOperator = interactor.engagedOperator
        action?(.setCallBubbleImage(imageUrl: engagedOperator?.picture?.url))
        action?(.setUnreadMessageIndicatorImage(imageUrl: engagedOperator?.picture?.url))

        guard let transferringItemIndex = messagesSection.items.firstIndex(where: {
            switch $0.kind {
            case .transferring: return true
            default: return false
            }
        }) else { return }

        messagesSection.removeItem(at: transferringItemIndex)
        action?(.refreshSection(messagesSection.index))
    }
}

// MARK: Section management

extension ChatViewModel {
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

    private func setItems(
        _ items: [ChatItem],
        to section: Section<ChatItem>
    ) {
        section.set(items)
        action?(.refreshAll)
    }
}

// MARK: History

extension ChatViewModel {
    private func loadHistory(_ completion: @escaping ([ChatMessage]) -> Void) {
        environment.fetchChatHistory { [weak self] result in
            guard let self else { return }
            let messages = (try? result.get()) ?? []
            // Store message ids from history,
            // to be able to discard duplicates
            // delivered by sockets.
            self.historyMessageIds = Set(messages.map(\.id))
            let items = messages.compactMap {
                ChatItem(
                    with: $0,
                    isCustomCardSupported: self.isCustomCardSupported,
                    fromHistory: self.environment.loadChatMessagesFromHistory()
                )
            }
            if let item = items.last, case .gvaQuickReply(_, let button, _, _) = item.kind {
                let props = button.options.map { self.quickReplyOption($0) }
                self.action?(.quickReplyPropsUpdated(.shown(props)))
            }

            self.historySection.set(items)
            self.action?(.refreshSection(self.historySection.index))
            self.action?(.scrollToBottom(animated: false))
            completion(messages)
        }
    }
}

// MARK: Media Upgrade

extension ChatViewModel {
    private func offerMediaUpgrade(
        _ offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        environment.alertManager.present(
            in: .global,
            as: .mediaUpgrade(
                operators: interactor.engagedOperator?.name ?? "",
                offer: offer,
                accepted: { [weak self] in
                    self?.delegate?(.mediaUpgradeAccepted(offer: offer, answer: answer))
                    self?.showCallBubble()
                },
                answer: answer
            )
        )
    }
}

// MARK: Message

extension ChatViewModel {
    func registerReceivedMessage(messageId: ChatMessage.MessageId) {
        self.receivedMessageIds.insert(messageId.uppercased())
    }

    func hasReceivedMessage(messageId: ChatMessage.MessageId) -> Bool {
        self.receivedMessageIds.contains(messageId.uppercased())
    }

    private func sendMessagePreview(_ message: String) {
        interactor.sendMessagePreview(message)
    }

    private func sendMessage() {
        guard validateMessage() else { return }

        let attachment = fileUploadListModel.attachment
        let uploads = fileUploadListModel.succeededUploads
        let files = uploads.map { $0.localFile }

        let payload = environment.createSendMessagePayload(messageText, attachment)

        let outgoingMessage = OutgoingMessage(
            payload: payload,
            files: files
        )

        switch interactor.state {
        case .engaged:
            let item = ChatItem(with: outgoingMessage)
            appendItem(item, to: messagesSection, animated: true)
            fileUploadListModel.succeededUploads.forEach { action?(.removeUpload($0)) }
            fileUploadListModel.removeSucceededUploads()
            action?(.scrollToBottom(animated: true))
            messageText = ""

            interactor.send(messagePayload: outgoingMessage.payload) { [weak self] result in
                guard let self else { return }

                switch result {
                case let .success(message):
                    if !self.hasReceivedMessage(messageId: message.id) {
                        self.registerReceivedMessage(messageId: message.id)
                        self.replace(
                            outgoingMessage,
                            uploads: uploads,
                            with: message,
                            in: self.messagesSection
                        )
                        self.action?(.scrollToBottom(animated: true))
                    }
                case .failure:
                    self.markMessageAsFailed(
                        outgoingMessage,
                        in: self.messagesSection
                    )
                }
            }
        case .enqueued:
            handle(pendingMessage: outgoingMessage)

        case .enqueueing, .ended, .none:
            handle(pendingMessage: outgoingMessage)
            interactor.state = .enqueueing(.chat)
        }

        messageText = ""
    }

    func handle(pendingMessage: OutgoingMessage) {
        switch interactor.state {
        case .engaged: return
        case .enqueueing, .enqueued, .ended, .none:
            let messageItem = ChatItem(with: pendingMessage)
            appendItem(messageItem, to: pendingSection, animated: true)

            fileUploadListModel.succeededUploads.forEach { action?(.removeUpload($0)) }
            fileUploadListModel.removeSucceededUploads()
            action?(.removeAllUploads)

            pendingMessages.append(pendingMessage)

            // Avoid showing enqueud operator according to parameter.
            if Self.shouldSkipEnqueueingState(for: chatType) {
                let queueItem = ChatItem(kind: .queueOperator)
                queueOperatorSection.set([queueItem])
                action?(.refreshSection(queueOperatorSection.index))
            }

            action?(.scrollToBottom(animated: true))
        }
    }

    func replace(
        _ outgoingMessage: OutgoingMessage,
        uploads: [FileUpload],
        with message: CoreSdkClient.Message,
        in section: Section<ChatItem>
    ) {
        SecureConversations.ChatWithTranscriptModel.replace(
            outgoingMessage.payload.messageId.rawValue,
            with: message,
            in: section,
            deliveredStatusText: deliveredStatusText,
            downloader: downloader,
            action: action
        )
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

    @discardableResult
    private func validateMessage() -> Bool {
        let canSendText = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let canSendAttachment =
            fileUploadListModel.state.value != .uploading
                && fileUploadListModel.failedUploads.isEmpty
                && !fileUploadListModel.succeededUploads.isEmpty
        let isValid = canSendText || canSendAttachment
        action?(.sendButtonDisabled(!isValid))
        return isValid
    }

    func addChatItemToMessagesSection(
            evaluating message: ChatMessage,
            replacingWith receivedMessage: CoreSdkClient.Message,
            _ item: ChatItem
    ) {
        // In order keep visitor session in sync between
        // multiple devices/web we need to treat visitor messages
        // with extra checks:
        if message.sender == .visitor {
            // Since message can be sent from current app,
            // we need to check if there's outgoing message
            // to match received message.
            var isMatchingOutgoingMessage = false
            // It is likely that outgoing message is located
            // at the end of message list (which is usually the case),
            // so traversing it in reversed order will save some
            // processing time.
            for chatItem in messagesSection.items.reversed() {
                switch chatItem.kind {
                case let .outgoingMessage(outgoingMessage, _)
                    where outgoingMessage.payload.messageId.rawValue.uppercased() == message.id.uppercased():
                    isMatchingOutgoingMessage = true
                default:
                    break
                }
                // Early out if match was found.
                if isMatchingOutgoingMessage {
                    break
                }
            }

            // If there's outgoing message, replace it
            // with delivered one.
            if isMatchingOutgoingMessage {
                SecureConversations.ChatWithTranscriptModel.replace(
                    message.id,
                    with: receivedMessage,
                    in: self.messagesSection,
                    deliveredStatusText: self.deliveredStatusText,
                    downloader: self.downloader,
                    action: self.action
                )
                // Otherwise append new message and
                // replace it with 'delivered' status.
            } else {
                appendItem(item, to: messagesSection, animated: true)
                SecureConversations.ChatWithTranscriptModel.replace(
                    message.id,
                    with: receivedMessage,
                    in: self.messagesSection,
                    deliveredStatusText: self.deliveredStatusText,
                    downloader: self.downloader,
                    action: self.action
                )
            }
        } else {
            // Non-visitor messages are to be just added
            // to `messageSection`.
            appendItem(item, to: messagesSection, animated: true)
        }
    }

    private func receivedMessage(_ message: CoreSdkClient.Message) {
        // Discard messages that have been already received from history
        // to avoid duplication.
        guard !historyMessageIds.contains(message.id) else {
            return
        }

        // Discard messages that have been already received.
        // This can happen in case if socket will delay
        // message delivery and it will be added during
        // REST API response.
        guard !hasReceivedMessage(messageId: message.id) else {
            return
        }

        // Discard pending message delivered via socket to
        // avoid message duplication. Currently pending messages
        // stay in pending section whole session.
        for pendingMessage in self.pendingSection.items {
            if case let .outgoingMessage(outgoingPendingMessage, _) = pendingMessage.kind,
                outgoingPendingMessage.payload.messageId.rawValue.uppercased() == message.id.uppercased() {
                return
            }
        }

        registerReceivedMessage(messageId: message.id)

        let receivedMessage = message

        switch message.sender.type {
        case .operator, .system, .visitor:
            let message = ChatMessage(
                with: message,
                operator: interactor.engagedOperator
            )
            if let item = ChatItem(
                with: message,
                isCustomCardSupported: isCustomCardSupported
            ) {
                unreadMessages.received(1)

                guard isViewLoaded else {
                    return
                }

                let isChatBottomReached = isChatScrolledToBottom.value

                addChatItemToMessagesSection(evaluating: message, replacingWith: receivedMessage, item)
                action?(.updateItemsUserImage(animated: true))

                let choiceCardInputModeEnabled = message.cardType == .choiceCard || self.isInteractableCustomCard(message)
                action?(.setChoiceCardInputModeEnabled(choiceCardInputModeEnabled))

                // Store info about choice card mode from which
                // attachment button visibility will be calculated.
                self.isChoiceCardInputModeEnabled = choiceCardInputModeEnabled

                if isChatBottomReached {
                    action?(.scrollToBottom(animated: true))
                }

                if case .gvaQuickReply(_, let button, _, _) = item.kind {
                    let props = button.options.map { quickReplyOption($0) }
                    action?(.quickReplyPropsUpdated(.shown(props)))
                }
            }
        default:
            // All Quick Reply buttons of the same set should disappear
            // after the user taps on one of the buttons or when
            // there is a new message from the user or GVA
            action?(.quickReplyPropsUpdated(.hidden))
        }
    }

    private func messagesUpdated(_ messages: [CoreSdkClient.Message]) {
        guard !messages.isEmpty else { return }
        unreadMessages.received(messages.count)

        let newMessages = messages.map { ChatMessage(with: $0) }
        let items = newMessages.compactMap {
            ChatItem(
                with: $0,
                isCustomCardSupported: isCustomCardSupported
            )
        }
        setItems(items, to: messagesSection)
        action?(.scrollToBottom(animated: true))
    }

    private func typingStatusUpdated(_ status: CoreSdkClient.OperatorTypingStatus) {
        action?(.setOperatorTypingIndicatorIsHiddenTo(
            !status.isTyping, isChatScrolledToBottom.value
        ))
    }
}

// MARK: File Attachments

extension ChatViewModel {
    private func presentMediaPicker() {
        let itemSelected = { (kind: AttachmentSourceItemKind) in
            let media = ObservableValue<MediaPickerEvent>(with: .none)
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

    private func fileTapped(_ file: LocalFile) {
        delegate?(.showFile(file))
    }

    func linkTapped(_ url: URL) {
        guard environment.uiApplication.canOpenURL(url) else {
            environment.log.prefixed(Self.self).error("No dialer uri - \(url)")
            return
        }
        environment.uiApplication.open(url)
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
}

// MARK: Message sending retry

extension ChatViewModel {
    private func retryMessageSending(_ outgoingMessage: OutgoingMessage) {
        removeMessage(
            outgoingMessage,
            in: messagesSection
        )

        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        interactor.send(messagePayload: outgoingMessage.payload) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(message):
                if !self.hasReceivedMessage(messageId: message.id) {
                    self.registerReceivedMessage(messageId: message.id)

                    self.replace(
                        outgoingMessage,
                        uploads: [],
                        with: message,
                        in: self.messagesSection
                    )
                    self.action?(.scrollToBottom(animated: true))
                }

                self.updateSelectedOption(with: outgoingMessage)
            case .failure:
                self.markMessageAsFailed(
                    outgoingMessage,
                    in: self.messagesSection
                )
            }
        }
    }

    // Updates Response Card or Custom Card selected option
    private func updateSelectedOption(with outgoingMessage: OutgoingMessage) {
        let selectedOption = outgoingMessage.payload.attachment?.selectedOption

        switch outgoingMessage.relation {
        case let .customCard(messageId):
            updateCustomCard(
                messageId: messageId,
                selectedOptionValue: selectedOption,
                isActive: false
            )
        case let .singleChoice(messageId):
            respond(to: messageId.rawValue, with: selectedOption)
        case .none:
            return
        }
    }
}

// MARK: General

extension ChatViewModel {
    var numberOfSections: Int { return sections.count }

    func numberOfItems(in section: Int) -> Int {
        return sections[section].itemCount
    }

    func item(for row: Int, in section: Int) -> ChatItem {
        SecureConversations.ChatWithTranscriptModel.item(
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

    private func isCustomCardActive(
        for row: Int,
        in section: Section<ChatItem>
    ) -> Bool {
        return section.item(after: row) == nil
    }

    func removePendingMessage(by messageId: String) {
        pendingMessages.removeAll { $0.payload.messageId.rawValue.uppercased() == messageId.uppercased() }
    }
}

// MARK: Call

extension ChatViewModel {
    private func onCall(_ call: Call?) {
        guard let call = call else { return }

        let callKind = ObservableValue<CallKind>(with: call.kind.value)
        let callDuration = ObservableValue<Int>(with: 0)
        let item = ChatItem(kind: .callUpgrade(callKind, duration: callDuration))
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        call.kind.addObserver(self) { kind, _ in
            callKind.value = kind
        }
        call.duration.addObserver(item) { duration, _ in
            callDuration.value = duration
        }
    }

    private func showCallBubble() {
        let imageUrl = interactor.engagedOperator?.picture?.url
        action?(.showCallBubble(imageUrl: imageUrl))
    }
}

// MARK: Site Configurations

extension ChatViewModel {
    func fetchSiteConfigurations() {
        environment.fetchSiteConfigurations { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let site):
                self.siteConfiguration = site
                self.action?(
                    .setAttachmentButtonEnabling(self.mediaPickerButtonEnabling)
                )
                self.showSnackBarIfNeeded()
            case let .failure(error):
                self.engagementAction?(.showAlert(.error(error: error)))
            }
        }
    }
}

extension ChatViewModel {
    static func shouldSkipEnqueueingState(for chatType: ChatType) -> Bool {
        switch chatType {
        case .secureTranscript: return true
        case .authenticated: return false
        case .nonAuthenticated: return false
        }
    }
}

#if DEBUG
extension ChatViewModel {
    /// Sets text and immediately sends it. Used for testing.
    func invokeSetTextAndSendMessage(text: String) {
        self.messageText = text
        self.sendMessage()
    }

    /// Sets pending messages list for unit testing
    func setPendingMessagesForTesting(_ message: [OutgoingMessage]) {
        self.pendingMessages = message
    }

    /// Gets pending messages list for unit testing
    func getPendingMessageForTesting() -> [OutgoingMessage] {
        self.pendingMessages
    }
}
#endif
