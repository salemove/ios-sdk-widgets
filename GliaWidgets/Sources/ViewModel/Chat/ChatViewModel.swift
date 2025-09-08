import Foundation
import Combine

// swiftlint:disable file_length
class ChatViewModel: EngagementViewModel {
    typealias ActionCallback = (Action) -> Void
    typealias DelegateCallback = (DelegateEvent) -> Void
    typealias AsyncDelegateCallback = (AsyncDelegateEvent) async -> Void

    var action: ActionCallback?
    var delegate: DelegateCallback?
    var asyncDelegate: AsyncDelegateCallback?
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
        guard !site.allowedFileContentTypes.isEmpty else { return .disabled }
        guard environment.getCurrentEngagement() != nil else {
            return .enabled(.engagementConnection(isConnected: false))
        }
        return .enabled(.engagementConnection(isConnected: environment.getCurrentEngagement() != nil))
    }

    private(set) var chatType: ChatType

    private var markMessagesAsReadCancellables = CancelBag()

    private(set) var entryWidget: EntryWidget?

    // swiftlint:disable function_body_length
    init(
        interactor: Interactor,
        call: ObservableValue<Call?>,
        unreadMessages: ObservableValue<Int>,
        showsCallBubble: Bool,
        isCustomCardSupported: Bool,
        isWindowVisible: ObservableValue<Bool>,
        startAction: StartAction,
        deliveredStatusText: String,
        failedToDeliverStatusText: String,
        chatType: ChatType,
        replaceExistingEnqueueing: Bool,
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
            replaceExistingEnqueueing: replaceExistingEnqueueing,
            environment: environment
        )
        do {
            self.entryWidget = try environment.createEntryWidget(makeEntryWidgetConfiguration())
        } catch {
            // Creating an entry widget may fail if the SDK is not configured.
            // This assumes that the SDK is configured by accessing Secure Conversations.
            environment.log.warning("Could not create EntryWidget on Secure Conversation")
        }
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
        isViewActive.addObserver(self) { [weak self] isViewActive, _ in
            if isViewActive {
                self?.environment.openTelemetry.logger.i(.chatScreenShown)
            } else {
                self?.environment.openTelemetry.logger.i(.chatScreenClosed)
            }
        }
    }
    // swiftlint:enable function_body_length

    override func viewDidAppear() {
        super.viewDidAppear()

        if showsCallBubble {
            showCallBubble()
        }
    }

    @MainActor
    override func start() async {
        await super.start()
        let history = await loadHistory()
        guard case .startEngagement = self.startAction else { return }
        if history.isEmpty || self.environment.getNonTransferredSecureConversationEngagement() != nil || self.replaceExistingEnqueueing {
            self.interactor.state = .enqueueing(.chat)
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

            action?(.enqueueing)
            action?(.scrollToBottom(animated: true))
        case .enqueued:
            action?(.enqueued)
        case .engaged(let engagedOperator) where interactor.currentEngagement?.isTransferredSecureConversation == false:
            environment.log.prefixed(Self.self).info("Operator connected")
            let name = engagedOperator?.firstName
            let pictureUrl = engagedOperator?.picture?.url
            let chatItem = ChatItem(kind: .operatorConnected)

            setItems([], to: queueOperatorSection)
            appendItem(
                chatItem,
                to: messagesSection,
                animated: false
            )

            action?(.connected(name: name, imageUrl: pictureUrl))
            action?(.scrollToBottom(animated: false))
            action?(.setMessageEntryEnabled(true))

            fetchSiteConfigurations()

            pendingMessages.forEach { [weak self] outgoingMessage in
                guard let self else { return }
                Task {
                    do {
                        let message = try await self.interactor.send(messagePayload: outgoingMessage.payload)
                        await self.onSuccessSendPendingMessages(
                            message: message,
                            outgoingMessage: outgoingMessage
                        )
                    } catch {
                        await self.onFailureSendPendingMessages(outgoingMessage: outgoingMessage)
                    }
                }
            }
        default:
            break
        }
    }

    @MainActor
    func onSuccessSendPendingMessages(
        message: CoreSdkClient.Message,
        outgoingMessage: OutgoingMessage
    ) {
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
    }

    @MainActor
    func onFailureSendPendingMessages(outgoingMessage: OutgoingMessage) {
        markMessageAsFailed(
            outgoingMessage,
            in: messagesSection
        )
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
            engagementAction?(.showCloseButton)
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

// MARK: Entry Widget
extension ChatViewModel {
    // Set up the Entry Widget configuration inside ChatViewModel,
    // since it requires passing view model logic to the configuration.
    private func makeEntryWidgetConfiguration() -> EntryWidget.Configuration {
        SecureConversations.ChatWithTranscriptModel.makeEntryWidgetConfiguration(
            with: .init { [weak self] mediaType in
                self?.entryWidgetMediaTypeSelected(mediaType)
            },
            mediaTypeItemsStyle: environment.topBannerItemsStyle
        )
    }

    private func entryWidgetMediaTypeSelected(_ item: EntryWidget.MediaTypeItem) {
        action?(.switchToEngagement)
        let switchToEngagement = { [weak self] in
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
        }
        if environment.shouldShowLeaveSecureConversationDialog(.entryWidgetTopBanner) {
            engagementAction?(.showAlert(.leaveCurrentConversation {
                switchToEngagement()
            }))
        } else {
            switchToEngagement()
        }
    }
}

extension ChatViewModel {
    @MainActor
    func asyncEvent(_ event: AsyncEvent) async {
        switch event {
        case .viewDidLoad:
            isViewLoaded = true
            await start()
        case .sendTapped:
            await sendMessage()
            action?(.quickReplyPropsUpdated(.hidden))
        case .customCardOptionSelected(let option, let messageId):
            await sendSelectedCustomCardOption(option, for: messageId)
        case .gvaButtonTapped(let option):
            await gvaOptionAction(for: option)()
        case .retryMessageTapped(let message):
            await retryMessageSending(message)
        case .choiceOptionSelected(let option, let messageId):
            await sendChoiceCardResponse(option, to: messageId)
        case .downloadTapped(let download):
            await downloadTapped(download)
        }
    }

    func event(_ event: Event) {
        switch event {
        case .messageTextChanged(let text):
            messageText = text
        case .removeUploadTapped(let upload):
            removeUpload(upload)
        case .pickMediaTapped:
            presentMediaPicker()
        case .callBubbleTapped:
            delegate?(.call)
        case .fileTapped(let file):
            fileTapped(file)
        case .chatScrolled(let bottomReached):
            isChatScrolledToBottom.value = bottomReached
        case .linkTapped(let url):
            linkTapped(url)
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
    @MainActor
    private func loadHistory() async -> [ChatMessage] {
        let messages = (try? await environment.fetchChatHistory()) ?? []

        // Store message ids from history,
        // to be able to discard duplicates
        // delivered by sockets.
        self.historyMessageIds = Set(messages.map(\.id).map { $0.uppercased() })

        // Remove all messages that have been already received from sockets
        // in prior of those that have been received from history to avoid duplication.
        let duplicatedIds = self.historyMessageIds.intersection(self.receivedMessageIds)
        duplicatedIds.forEach { self.receivedMessageIds.remove($0) }

        self.messagesSection.removeAll { item in
            switch item.kind {
            case .visitorMessage(let chatMessage, _) where duplicatedIds.contains(chatMessage.id.uppercased()):
                return true
            case .operatorMessage(let chatMessage, _, _) where duplicatedIds.contains(chatMessage.id.uppercased()):
                return true
            default:
                return false
            }
        }

        self.action?(.refreshSection(self.messagesSection.index))

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

        return messages
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
                operators: interactor.engagedOperator?.firstName ?? "",
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
    // In case when Tranferred SC exists and `chatType` is `.authenticated`
    // that means visitor decided to Leave Current Conversation and
    // then authenticated Chat was opened.
    // In this case we need to force enqueueing process instead of sending a message.
    var shouldForceEnqueueing: Bool {
        let hasTransferredSecureConversation = interactor.currentEngagement?.isTransferredSecureConversation == true
        return hasTransferredSecureConversation && chatType == .authenticated
    }

    func registerReceivedMessage(messageId: ChatMessage.MessageId) {
        self.receivedMessageIds.insert(messageId.uppercased())
    }

    func hasReceivedMessage(messageId: ChatMessage.MessageId) -> Bool {
        self.receivedMessageIds.contains(messageId.uppercased())
    }

    private func sendMessagePreview(_ message: String) {
        Task {
            _ = try? await interactor.sendMessagePreview(message)
        }
    }

    @MainActor
    private func sendMessage() async {
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
        case .engaged where shouldForceEnqueueing, .enqueueing, .ended, .none:
            handle(pendingMessage: outgoingMessage)
            interactor.state = .enqueueing(.chat)
        case .engaged:
            let item = ChatItem(with: outgoingMessage)
            appendItem(item, to: messagesSection, animated: true)
            fileUploadListModel.succeededUploads.forEach { action?(.removeUpload($0)) }
            fileUploadListModel.removeSucceededUploads()
            action?(.scrollToBottom(animated: true))
            messageText = ""

            do {
                let message = try await interactor.send(messagePayload: outgoingMessage.payload)
                onSuccessSendMessage(
                    message: message,
                    outgoingMessage: outgoingMessage,
                    uploads: uploads
                )
            } catch {
                onFailureSendMessage(outgoingMessage: outgoingMessage)
            }
        case .enqueued:
            handle(pendingMessage: outgoingMessage)
        }

        messageText = ""
    }

    @MainActor
    func onSuccessSendMessage(
        message: CoreSdkClient.Message,
        outgoingMessage: OutgoingMessage,
        uploads: [FileUpload]
    ) {
        if !hasReceivedMessage(messageId: message.id) {
            registerReceivedMessage(messageId: message.id)
            replace(
                outgoingMessage,
                uploads: uploads,
                with: message,
                in: messagesSection
            )
            action?(.scrollToBottom(animated: true))
        }
    }

    @MainActor
    func onFailureSendMessage(outgoingMessage: OutgoingMessage) {
        markMessageAsFailed(
            outgoingMessage,
            in: messagesSection
        )
    }

    func handle(pendingMessage: OutgoingMessage) {
        switch interactor.state {
        case .engaged where shouldForceEnqueueing, .enqueueing, .enqueued, .ended, .none:
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
        case .engaged: return
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
        defer {
            switch item.kind {
            case .gvaGallery, .gvaQuickReply, .gvaPersistentButton:
                environment.openTelemetry.logger.i(.chatScreenGvaMessageShown) {
                    $0[.messageId] = .string(receivedMessage.id)
                }
            case .customCard:
                environment.openTelemetry.logger.i(.chatScreenCustomCardShown) {
                    $0[.messageId] = .string(receivedMessage.id)
                }
            case .choiceCard:
                environment.openTelemetry.logger.i(.chatScreenSingleChoiceShown) {
                    $0[.messageId] = .string(receivedMessage.id)
                }
            default:
                environment.openTelemetry.logger.i(.chatScreenMessageShown) {
                    $0[.messageId] = .string(receivedMessage.id)
                    $0[.messageSender] = .string(receivedMessage.sender.type.rawValue)

                    // The same values. Needed?
                    $0[.messageType] = .string(receivedMessage.sender.type.rawValue)
                }
            }
        }

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
        guard !historyMessageIds.contains(message.id.uppercased()) else {
            return
        }

        // Discard messages that have been already received.
        // This can happen in case if socket will delay
        // message delivery and it will be added during
        // REST API response.
        guard !hasReceivedMessage(messageId: message.id.uppercased()) else {
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

        switch message.sender.type {
        case .operator, .system, .visitor:
            handleReceivedMessage(message)

        default:
            // All Quick Reply buttons of the same set should disappear
            // after the user taps on one of the buttons or when
            // there is a new message from the user or GVA
            action?(.quickReplyPropsUpdated(.hidden))
        }

        markMessagesAsRead(
            with: message.sender.type != .visitor && environment.getCurrentEngagement()?.actionOnEnd == .retain
        )
    }

    private func handleReceivedMessage(_ receivedMessage: CoreSdkClient.Message) {
        let message = ChatMessage(
            with: receivedMessage,
            operator: interactor.engagedOperator
        )
        guard let item = ChatItem(
            with: message,
            isCustomCardSupported: isCustomCardSupported
        ), isViewLoaded else { return }

        if receivedMessage.sender.type != .visitor {
            unreadMessages.received(1)
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
        let logMediaSourceSelection = { [weak self] (kind: AttachmentSourceItemKind) in
            self?.environment.openTelemetry.logger.i(.chatScreenButtonClicked) {
                switch kind {
                case .photoLibrary:
                    $0[.buttonName] = .string(OtelButtonNames.selectFromLibrary.rawValue)
                case .takePhotoOrVideo:
                    $0[.buttonName] = .string(OtelButtonNames.takePhotoVideo.rawValue)
                case .takePhoto:
                    $0[.buttonName] = .string(OtelButtonNames.takePhoto.rawValue)
                case .takeVideo:
                    $0[.buttonName] = .string(OtelButtonNames.takeVideo.rawValue)
                case .browse:
                    $0[.buttonName] = .string(OtelButtonNames.browseFiles.rawValue)
                }
            }
        }
        let itemSelected = { (kind: AttachmentSourceItemKind) in
            logMediaSourceSelection(kind)
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
                self.delegate?(.pickMedia(media, self.allowedMediaTypes))
            case .takePhotoOrVideo:
                self.delegate?(.takeMedia(media, [.image, .movie]))
            case .takePhoto:
                self.delegate?(.takeMedia(media, [.image]))
            case .takeVideo:
                self.delegate?(.takeMedia(media, [.movie]))
            case .browse:
                self.delegate?(.pickFile(file, .custom(self.allowedFileContentTypes.mimeTypesToUTIs())))
            }
        }
        action?(.presentMediaPicker(allowedAttachmentOptions, itemSelected: { itemSelected($0) }))
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

    @MainActor
    private func downloadTapped(_ download: FileDownload) async {
        switch download.state.value {
        case .none:
            await download.startDownload()
        case .downloading:
            break
        case .downloaded(let file):
            delegate?(.showFile(file))
        case .error:
            await download.startDownload()
        }
    }
}

// MARK: Message sending retry

extension ChatViewModel {
    @MainActor
    private func retryMessageSending(_ outgoingMessage: OutgoingMessage) async {
        removeMessage(
            outgoingMessage,
            in: messagesSection
        )

        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        do {
            let message = try await interactor.send(messagePayload: outgoingMessage.payload)
            onSuccessRetryMessageSending(
                message: message,
                outgoingMessage: outgoingMessage
            )
        } catch {
            onFailureRetryMessageSending(outgoingMessage: outgoingMessage)
        }
    }

    @MainActor
    func onSuccessRetryMessageSending(
        message: CoreSdkClient.Message,
        outgoingMessage: OutgoingMessage
    ) {
        if !hasReceivedMessage(messageId: message.id) {
            registerReceivedMessage(messageId: message.id)

            replace(
                outgoingMessage,
                uploads: [],
                with: message,
                in: messagesSection
            )
            action?(.scrollToBottom(animated: true))
        }

        updateSelectedOption(with: outgoingMessage)
    }

    @MainActor
    func onFailureRetryMessageSending(outgoingMessage: OutgoingMessage) {
        markMessageAsFailed(
            outgoingMessage,
            in: messagesSection
        )
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

// MARK: Mark messages as read
extension ChatViewModel: ApplicationVisibilityTracker {
    // The method is used to mark messages as read with delay
    // when the app and screen are visible or become visible.
    // - Parameters:
    //   - predicate: A boolean value that determines whether messages should be marked as read.
    func markMessagesAsRead(with predicate: Bool = true) {
        guard predicate else {
            return
        }
        markMessagesAsReadCancellables.removeAll()
        isViewVisiblePublisher(
            for: environment.uiApplication.applicationState(),
            notificationCenter: environment.notificationCenter,
            isViewVisiblePublisher: isViewActive.toCombinePublisher(),
            resumeToForegroundDelay: environment.markUnreadMessagesDelay(),
            delayScheduler: environment.combineScheduler.global
        )
        .sink { [weak self] _ in
            Task {
                try? await self?.environment.secureConversations.markMessagesAsRead()
            }
        }
        .store(in: &markMessagesAsReadCancellables)
    }
}

extension ChatViewModel: AttachmentOptions {
    var allowedFileContentTypes: [String] {
        guard let site = siteConfiguration else { return [] }
        return site.allowedFileContentTypes
    }
}

#if DEBUG
extension ChatViewModel {
    /// Sets text and immediately sends it. Used for testing.
    @MainActor
    func invokeSetTextAndSendMessage(text: String) async {
        self.messageText = text
        await self.sendMessage()
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
// swiftlint:enable file_length
