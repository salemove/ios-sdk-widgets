import SalemoveSDK

class ChatViewModel: EngagementViewModel, ViewModel {
    typealias Strings = L10n.Chat

    enum Event {
        case viewDidLoad
        case messageTextChanged(String)
        case sendTapped
        case removeUploadTapped(FileUpload)
        case pickMediaTapped
        case callBubbleTapped
        case fileTapped(LocalFile)
        case downloadTapped(FileDownload)
        case choiceOptionSelected(ChatChoiceCardOption, String)
        case chatScrolled(bottomReached: Bool)
        case linkTapped(URL)
        case willDisplayItem(ChatItem)
    }

    enum Action {
        case queue
        case connected(name: String?, imageUrl: String?)
        case setMessageEntryEnabled(Bool)
        case setChoiceCardInputModeEnabled(Bool)
        case setMessageText(String)
        case sendButtonHidden(Bool)
        case pickMediaButtonEnabled(Bool)
        case appendRows(Int, to: Int, animated: Bool)
        case refreshRow(Int, in: Int, animated: Bool)
        case refreshRows([Int], in: Int, animated: Bool)
        case refreshSection(Int)
        case refreshAll
        case scrollToBottom(animated: Bool)
        case updateItemsUserImage(animated: Bool)
        case addUpload(FileUpload)
        case removeUpload(FileUpload)
        case removeAllUploads
        case presentMediaPicker(itemSelected: (AtttachmentSourceItemKind) -> Void)
        case showCallBubble(imageUrl: String?)
        case updateUnreadMessageIndicator(itemCount: Int)
        case setOperatorTypingIndicatorIsHiddenTo(Bool, _ isChatScrolledToBottom: Bool)
    }

    enum DelegateEvent {
        case pickMedia(CurrentValueSubject<MediaPickerEvent>)
        case takeMedia(CurrentValueSubject<MediaPickerEvent>)
        case pickFile(CurrentValueSubject<FilePickerEvent>)
        case showFile(LocalFile)
        case callBubbleTapped
        case openLink(URL)
    }

    enum StartAction {
        case startEngagement
        case none
    }

    var action: ((Action) -> Void)?
    var delegate: ((DelegateEvent) -> Void)?

    private let startAction: StartAction
    private let sections = [
        Section<ChatItem>(0),
        Section<ChatItem>(1),
        Section<ChatItem>(2),
        Section<ChatItem>(3)
    ]
    private var historySection: Section<ChatItem> { sections[0] }
    private var pendingSection: Section<ChatItem> { sections[1] }
    private var queueOperatorSection: Section<ChatItem> { sections[2] }
    private var messagesSection: Section<ChatItem> { sections[3] }
    private let messageDispatcher: MessageDispatcher
    private let screenShareHandler: ScreenShareHandler
    private let isChatScrolledToBottom = CurrentValueSubject<Bool>(true)
    private let showsCallBubble: Bool
    private let storage = ChatStorage()
    private let uploader = FileUploader(maximumUploads: 25)
    private let downloader = FileDownloader()
    private var messageText = "" {
        didSet {
            validateMessage()
            sendMessagePreview(messageText)
            action?(.setMessageText(messageText))
        }
    }

    private var pendingMessages: [OutgoingMessage] = []
    private var isViewLoaded: Bool = false
    private var disposables: [Disposable] = []

    init(
        interactor: Interactor,
        alertConfiguration: AlertConfiguration,
        screenShareHandler: ScreenShareHandler,
        messageDispatcher: MessageDispatcher,
        showsCallBubble: Bool,
        startAction: StartAction
    ) {
        self.showsCallBubble = showsCallBubble
        self.startAction = startAction
        self.screenShareHandler = screenShareHandler
        self.messageDispatcher = messageDispatcher

        super.init(
            interactor: interactor,
            screenShareHandler: screenShareHandler
        )

        uploader.state
            .observe({ [weak self] in
                self?.onUploaderStateChanged($0)
            })
            .add(to: &disposables)

        uploader.limitReached
            .observe({ [weak self] in
                self?.action?(.pickMediaButtonEnabled(!$0))
            })
            .add(to: &disposables)

        messageDispatcher.messageReceived
            .observe({ [weak self] in
                self?.receivedMessage($0)
            })
            .add(to: &disposables)
    }

    func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
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
            delegate?(.callBubbleTapped)
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
        case .willDisplayItem(let item):
            willDisplayItem(item)
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

        loadHistory()

        if case .startEngagement = startAction {
            if storage.isEmpty() {
                let item = ChatItem(kind: .queueOperator)

                appendItem(
                    item,
                    to: queueOperatorSection,
                    animated: false
                )

                enqueue(mediaType: .text)
            }
        }

        update(for: interactor.state)
    }

    override func update(for state: InteractorState) {
        super.update(for: state)

        switch state {
        case .enqueueing:
            action?(.queue)
            action?(.scrollToBottom(animated: false))

        case .engaged(let engagedOperator):
            let name = engagedOperator?.firstName
            let pictureUrl = engagedOperator?.picture?.url
            action?(.connected(name: name, imageUrl: pictureUrl))
            action?(.setMessageEntryEnabled(true))

            if let screenShareStatus = screenShareHandler.status.value {
                switch screenShareStatus {
                case .started:
                    engagementAction?(.showEndScreenShareButton)

                case .stopped:
                    engagementAction?(.showEndButton)
                }
            }

            pendingMessages.forEach { [weak self] outgoingMessage in
                self?.interactor.send(outgoingMessage.content, attachment: nil) { [weak self] message in
                    guard let self = self else { return }

                    self.replace(
                        outgoingMessage,
                        uploads: [],
                        with: message,
                        in: self.messagesSection
                    )

                    self.action?(.scrollToBottom(animated: true))
                } failure: { [weak self] _ in
                    self?.engagementDelegate?(
                        .alert(.unexpectedError)
                    )
                }
            }

        default:
            break
        }
    }

    override func interactorEvent(_ event: InteractorEvent) {
        super.interactorEvent(event)

        switch event {
        case .messagesUpdated(let messages):
            messagesUpdated(messages)
        case .typingStatusUpdated(let status):
            typingStatusUpdated(status)
        default:
            break
        }
    }
}

// MARK: Section management

extension ChatViewModel {
    private func appendItem(
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
    private func loadHistory() {
        let messages = storage.messages(forQueue: interactor.queueID)
        let items = messages.compactMap { ChatItem(with: $0, fromHistory: true) }
        historySection.set(items)
        action?(.refreshSection(historySection.index))
        action?(.scrollToBottom(animated: false))
    }
}

// MARK: Message

extension ChatViewModel {
    private func willDisplayItem(_ item: ChatItem) {
        switch item.kind {
        case .operatorMessage(let message, _, _):
            messageDispatcher.markMessageAsRead(messageId: message.id)

        case .choiceCard(let message, _, _, _):
            messageDispatcher.markMessageAsRead(messageId: message.id)

        case .visitorMessage(let message, _):
            messageDispatcher.markMessageAsRead(messageId: message.id)

        default:
            break
        }
    }

    private func sendMessagePreview(_ message: String) {
        interactor.sendMessagePreview(message)
    }

    private func sendMessage() {
        guard validateMessage() else { return }

        let attachment = uploader.attachment
        let uploads = uploader.succeededUploads
        let files = uploads.map { $0.localFile }
        let outgoingMessage = OutgoingMessage(
            content: messageText,
            files: files
        )

        if interactor.isEngaged {
            let item = ChatItem(with: outgoingMessage)
            appendItem(item, to: messagesSection, animated: true)
            uploader.succeededUploads.forEach { action?(.removeUpload($0)) }
            uploader.removeSucceededUploads()
            action?(.scrollToBottom(animated: true))
            let messageTextTemp = messageText
            messageText = ""

            interactor.send(messageTextTemp, attachment: attachment) { [weak self] message in
                guard let self = self else { return }

                self.replace(
                    outgoingMessage,
                    uploads: uploads,
                    with: message,
                    in: self.messagesSection
                )

                self.action?(.scrollToBottom(animated: true))
            } failure: { [weak self] _ in
                self?.engagementDelegate?(
                    .alert(.unexpectedError)
                )
            }
        } else {
            let messageItem = ChatItem(with: outgoingMessage)
            appendItem(messageItem, to: pendingSection, animated: true)

            uploader.succeededUploads.forEach { action?(.removeUpload($0)) }
            uploader.removeSucceededUploads()
            action?(.removeAllUploads)

            pendingMessages.append(outgoingMessage)

            let queueItem = ChatItem(kind: .queueOperator)

            queueOperatorSection.set([queueItem])
            action?(.refreshSection(2))
            action?(.scrollToBottom(animated: true))

            enqueue(mediaType: .text)
        }

        messageText = ""
    }

    private func replace(
        _ outgoingMessage: OutgoingMessage,
        uploads: [FileUpload],
        with message: Message,
        in section: Section<ChatItem>
    ) {
        guard let index = section.items
            .enumerated()
            .first(where: {
                guard case .outgoingMessage(let message) = $0.element.kind else { return false }
                return message.id == outgoingMessage.id
            })?.offset
        else { return }

        let deliveredStatus = Strings.Message.Status.delivered
        var affectedRows = [Int]()

        // Remove previous "Delivered" statuses
        section.items
            .enumerated()
            .forEach { index, element in
                if case .visitorMessage(let message, let status) = element.kind,
                   status == deliveredStatus {
                    let chatItem = ChatItem(kind: .visitorMessage(message, status: nil))
                    section.replaceItem(at: index, with: chatItem)
                    affectedRows.append(index)
                }
            }

        let deliveredMessage = ChatMessage(with: message)
        let item = ChatItem(kind: .visitorMessage(deliveredMessage, status: deliveredStatus))
        downloader.addDownloads(for: deliveredMessage.attachment?.files)
        section.replaceItem(at: index, with: item)
        affectedRows.append(index)
        action?(.refreshRows(affectedRows, in: section.index, animated: false))
    }

    @discardableResult
    private func validateMessage() -> Bool {
        let canSendText = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let canSendAttachment =
            uploader.state.value != .uploading
                && uploader.failedUploads.isEmpty
                && !uploader.succeededUploads.isEmpty
        let isValid = canSendText || canSendAttachment
        action?(.sendButtonHidden(!isValid))
        return isValid
    }

    private func receivedMessage(_ message: Message?) {
        guard let message = message else {
            return
        }

        switch message.sender {
        case .operator:
            let message = ChatMessage(
                with: message,
                operator: interactor.engagedOperator
            )
            if let item = ChatItem(with: message) {
                guard isViewLoaded else { return }

                let isChatBottomReached = isChatScrolledToBottom.value

                appendItem(item, to: messagesSection, animated: true)
                action?(.updateItemsUserImage(animated: true))
                action?(.setChoiceCardInputModeEnabled(message.isChoiceCard))

                if isChatBottomReached {
                    action?(.scrollToBottom(animated: true))
                }
            }
        default:
            break
        }
    }

    private func messagesUpdated(_ messages: [Message]) {
        let newMessages = storage.newMessages(messages)

        if !newMessages.isEmpty {
            storage.storeMessages(
                newMessages,
                queueID: interactor.queueID,
                operator: interactor.engagedOperator
            )
            let newMessages = newMessages.map { ChatMessage(with: $0) }
            let items = newMessages.compactMap { ChatItem(with: $0) }
            setItems(items, to: messagesSection)
            action?(.scrollToBottom(animated: true))
        }
    }

    private func typingStatusUpdated(_ status: OperatorTypingStatus) {
        action?(.setOperatorTypingIndicatorIsHiddenTo(
            !status.isTyping, isChatScrolledToBottom.value
        ))
    }
}

// MARK: File Attachments

extension ChatViewModel {
    private func presentMediaPicker() {
        let itemSelected = { [weak self] (kind: AtttachmentSourceItemKind) -> Void in
            guard let self = self else { return }

            let media = CurrentValueSubject<MediaPickerEvent>(.none)

            media
                .observe({ [weak self] in
                    switch $0 {
                    case .none, .cancelled:
                        break

                    case .pickedMedia(let media):
                        self?.mediaPicked(media)

                    case .sourceNotAvailable:
                        self?.engagementDelegate?(
                            .alert(.mediaSourceError)
                        )

                    case .noCameraPermission:
                        self?.engagementDelegate?(
                            .alert(.cameraSettings)
                        )
                    }
                })
                .add(to: &self.disposables)

            let file = CurrentValueSubject<FilePickerEvent>(.none)

            file
                .observe({ [weak self] in
                    switch $0 {
                    case .none, .cancelled:
                        break

                    case .pickedFile(let url):
                        self?.filePicked(url)
                    }
                })
                .add(to: &self.disposables)

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
        guard let upload = uploader.addUpload(with: url) else { return }
        action?(.addUpload(upload))
    }

    private func addUpload(with data: Data, format: MediaFormat) {
        guard let upload = uploader.addUpload(with: data, format: format) else { return }
        action?(.addUpload(upload))
    }

    private func removeUpload(_ upload: FileUpload) {
        uploader.removeUpload(upload)
        action?(.removeUpload(upload))
        validateMessage()
    }

    private func onUploaderStateChanged(_ state: FileUploader.State) {
        validateMessage()
    }

    private func fileTapped(_ file: LocalFile) {
        delegate?(.showFile(file))
    }

    private func linkTapped(_ url: URL) {
        delegate?(.openLink(url))
    }

    private func downloadTapped(_ download: FileDownload) {
        guard
            let state = download.state.value
        else { return }

        switch state {
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

// MARK: General

extension ChatViewModel {
    var numberOfSections: Int { return sections.count }

    func numberOfItems(in section: Int) -> Int {
        return sections[section].itemCount
    }

    func item(for row: Int, in section: Int) -> ChatItem {
        let section = sections[section]
        let item = section[row]

        switch item.kind {
        case .operatorMessage(let message, _, _):
            message.downloads = downloader.downloads(
                for: message.attachment?.files,
                autoDownload: .images
            )

            if shouldShowOperatorImage(for: row, in: section) {
                let imageUrl = message.operator?.pictureUrl
                let kind: ChatItem.Kind = .operatorMessage(
                    message,
                    showsImage: true,
                    imageUrl: imageUrl
                )
                return ChatItem(kind: kind)
            }

            return item

        case .visitorMessage(let message, _):
            message.downloads = downloader.downloads(
                for: message.attachment?.files,
                autoDownload: .images
            )

            return item

        case .choiceCard(let message, _, _, let isActive):
            if shouldShowOperatorImage(for: row, in: section) {
                let imageUrl = message.operator?.pictureUrl
                let kind: ChatItem.Kind = .choiceCard(
                    message,
                    showsImage: true,
                    imageUrl: imageUrl,
                    isActive: isActive
                )
                return ChatItem(kind: kind)
            }

            return item

        default:
            return item
        }
    }

    private func shouldShowOperatorImage(
        for row: Int,
        in section: Section<ChatItem>
    ) -> Bool {
        guard section[row].isOperatorMessage else { return false }
        let nextItem = section.item(after: row)

        return nextItem == nil || nextItem?.isOperatorMessage == false
    }
}

// MARK: Call

extension ChatViewModel {
    private func showCallBubble() {
        let imageUrl = interactor.engagedOperator?.picture?.url
        action?(.showCallBubble(imageUrl: imageUrl))
    }
}

// MARK: Choice Card

extension ChatViewModel {
    private func sendChoiceCardResponse(_ option: ChatChoiceCardOption, to messageId: String) {
        guard let value = option.value else { return }

        Salemove.sharedInstance.send(
            selectedOptionValue: value
        ) { [weak self] result in
            switch result {
            case .success(let message):
                guard
                    let selection = message.attachment?.selectedOption
                else { return }

                self?.respond(to: messageId, with: selection)

            case .failure:
                self?.engagementDelegate?(
                    .alert(.unexpectedError)
                )
            }
        }
    }

    private func respond(to choiceCardId: String, with selection: String?) {
        guard let index = messagesSection.items
            .enumerated()
            .first(where: {
                guard case .choiceCard(let message, _, _, _) = $0.element.kind
                else { return false }
                return message.id == choiceCardId
            })?.offset
        else { return }

        let choiceCard = messagesSection[index]

        guard case .choiceCard(
            let message,
            let showsImage,
            let imageUrl,
            _
        ) = choiceCard.kind else { return }

        message.attachment?.selectedOption = selection
        message.queueID = interactor.queueID
        let item = ChatItem(kind: .choiceCard(
            message,
            showsImage: showsImage,
            imageUrl: imageUrl,
            isActive: false
        ))

        messagesSection.replaceItem(at: index, with: item)
        storage.updateMessage(message)

        action?(.refreshRow(index, in: messagesSection.index, animated: true))
        action?(.setChoiceCardInputModeEnabled(false))
    }
}
