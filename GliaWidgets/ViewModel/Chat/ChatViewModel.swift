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
        case presentMediaPicker(itemSelected: (ListItemKind) -> Void)
        case offerMediaUpgrade(
            SingleMediaUpgradeAlertConfiguration,
            accepted: () -> Void,
            declined: () -> Void
        )
        case showCallBubble(imageUrl: String?)
        case updateUnreadMessageIndicator(itemCount: Int)
    }

    enum DelegateEvent {
        case pickMedia(ObservableValue<MediaPickerEvent>)
        case takeMedia(ObservableValue<MediaPickerEvent>)
        case pickFile(ObservableValue<FilePickerEvent>)
        case mediaUpgradeAccepted(
            offer: MediaUpgradeOffer,
            answer: AnswerWithSuccessBlock
        )
        case showFile(LocalFile)
        case call
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
        Section<ChatItem>(2)
    ]
    private var historySection: Section<ChatItem> { return sections[0] }
    private var queueOperatorSection: Section<ChatItem> { return sections[1] }
    private var messagesSection: Section<ChatItem> { return sections[2] }
    private let call: ObservableValue<Call?>
    private var unreadMessages: UnreadMessagesHandler!
    private let isChatScrolledToBottom = ObservableValue<Bool>(with: true)
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

    init(
        interactor: Interactor,
        alertConfiguration: AlertConfiguration,
        screenShareHandler: ScreenShareHandler,
        call: ObservableValue<Call?>,
        unreadMessages: ObservableValue<Int>,
        showsCallBubble: Bool,
        isWindowVisible: ObservableValue<Bool>,
        startAction: StartAction
    ) {
        self.call = call
        self.showsCallBubble = showsCallBubble
        self.startAction = startAction
        super.init(
            interactor: interactor,
            alertConfiguration: alertConfiguration,
            screenShareHandler: screenShareHandler
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

    public func event(_ event: Event) {
        switch event {
        case .viewDidLoad:
            start()
        case .messageTextChanged(let text):
            messageText = text
        case .sendTapped:
            sendMessage()
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

        let item = ChatItem(kind: .queueOperator)
        appendItem(
            item,
            to: queueOperatorSection,
            animated: false
        )
        action?(.setMessageEntryEnabled(false))
        action?(.sendButtonHidden(true))

        switch startAction {
        case .startEngagement:
            enqueue()
        case .none:
            update(for: interactor.state)
        }
    }

    override func update(for state: InteractorState) {
        super.update(for: state)

        switch state {
        case .enqueueing:
            action?(.queue)
        case .engaged(let engagedOperator):
            let name = engagedOperator?.firstName
            let pictureUrl = engagedOperator?.picture?.url
            action?(.connected(name: name, imageUrl: pictureUrl))
            action?(.setMessageEntryEnabled(true))
            engagementAction?(.showEndButton)
            loadHistory()
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

// MARK: Media Upgrade

extension ChatViewModel {
    private func offerMediaUpgrade(
        _ offer: MediaUpgradeOffer,
        answer: @escaping AnswerWithSuccessBlock
    ) {
        switch offer.type {
        case .audio:
            offerMediaUpgrade(
                with: alertConfiguration.audioUpgrade,
                offer: offer,
                answer: answer
            )
        case .video:
            let configuration = offer.direction == .oneWay
                ? alertConfiguration.oneWayVideoUpgrade
                : alertConfiguration.twoWayVideoUpgrade
            offerMediaUpgrade(
                with: configuration,
                offer: offer,
                answer: answer
            )
        default:
            break
        }
    }

    private func offerMediaUpgrade(
        with configuration: SingleMediaUpgradeAlertConfiguration,
        offer: MediaUpgradeOffer,
        answer: @escaping AnswerWithSuccessBlock
    ) {
        guard isViewActive.value else { return }
        let operatorName = interactor.engagedOperator?.firstName
        let onAccepted = {
            self.delegate?(.mediaUpgradeAccepted(offer: offer, answer: answer))
            self.showCallBubble()
        }
        action?(.offerMediaUpgrade(
            configuration.withOperatorName(operatorName),
            accepted: { onAccepted() },
            declined: { answer(false, nil) }
        ))
    }
}

// MARK: Message

extension ChatViewModel {
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
        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        uploader.removeAllUploads()
        action?(.removeAllUploads)
        action?(.scrollToBottom(animated: true))
        let messageTextTemp = messageText
        messageText = ""

        interactor.send(messageTextTemp, attachment: attachment) { message in
            self.replace(
                outgoingMessage,
                uploads: uploads,
                with: message,
                in: self.messagesSection
            )

            self.action?(.scrollToBottom(animated: true))
        } failure: { _ in
            self.showAlert(with: self.alertConfiguration.unexpectedError,
                           dismissed: nil)
        }
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
        downloader.addDownloads(for: deliveredMessage.attachment?.files, with: uploads)
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

    private func receivedMessage(_ message: Message) {
        guard storage.isNewMessage(message) else { return }

        storage.storeMessage(
            message,
            queueID: interactor.queueID,
            operator: interactor.engagedOperator
        )

        switch message.sender {
        case .operator:
            let message = ChatMessage(
                with: message,
                operator: interactor.engagedOperator
            )
            if let item = ChatItem(with: message) {
                let isChatBottomReached = isChatScrolledToBottom.value
                appendItem(item, to: messagesSection, animated: true)
                action?(.updateItemsUserImage(animated: true))

                action?(.setChoiceCardInputModeEnabled(message.isChoiceCard))
                if isChatBottomReached {
                    action?(.scrollToBottom(animated: true))
                }
                unreadMessages.received(1)
            }
        default:
            break
        }
    }

    private func messagesUpdated(_ messages: [Message]) {
        let newMessages = storage.newMessages(messages)
        unreadMessages.received(newMessages.count)

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
}

// MARK: File Attachments

extension ChatViewModel {
    private func presentMediaPicker() {
        let itemSelected = { (kind: ListItemKind) -> Void in
            let media = ObservableValue<MediaPickerEvent>(with: .none)
            media.addObserver(self) { [weak self] event, _ in
                guard let self = self else { return }
                switch event {
                case .none, .cancelled:
                    break
                case .pickedMedia(let media):
                    self.mediaPicked(media)
                case .sourceNotAvailable:
                    self.showAlert(
                        with: self.alertConfiguration.mediaSourceNotAvailable,
                        dismissed: nil
                    )
                case .noCameraPermission:
                    self.showSettingsAlert(with: self.alertConfiguration.cameraSettings)
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

// MARK: Choice Card

extension ChatViewModel {
    private func sendChoiceCardResponse(_ option: ChatChoiceCardOption, to messageId: String) {
        guard let value = option.value else { return }
        print("Sending option \(value) to message with id \(messageId)...")
        Salemove.sharedInstance.send(
            selectedOptionValue: value,
            messageId: messageId
        ) { [weak self] message, error in
            guard let self = self else { return }

            if error != nil {
                self.showAlert(
                    with: self.alertConfiguration.unexpectedError,
                    dismissed: nil
                )
            }

            guard let message = message,
                  let selection = message.attachment?.selectedOption
            else { return }

            print("Confirmed: SDK received option \(selection) for message with id \(message.id)")
            self.respond(to: messageId, with: selection)
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
