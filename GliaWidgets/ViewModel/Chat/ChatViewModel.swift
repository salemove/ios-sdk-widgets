import SalemoveSDK

class ChatViewModel: EngagementViewModel, ViewModel {
    typealias Strings = L10n.Chat

    enum Event {
        case viewDidLoad
        case messageTextChanged(String)
        case sendTapped
        case removeUploadTapped(Int)
        case pickMediaTapped
        case callBubbleTapped
    }

    enum Action {
        case queue
        case showEndButton
        case connected(name: String?, imageUrl: String?)
        case setMessageEntryEnabled(Bool)
        case setMessageText(String)
        case sendButtonHidden(Bool)
        case appendRows(Int, to: Int, animated: Bool)
        case refreshRow(Int, in: Int, animated: Bool)
        case refreshSection(Int)
        case refreshAll
        case scrollToBottom(animated: Bool)
        case updateItemsUserImage(animated: Bool)
        case addUpload(FileUpload)
        case removeUpload(Int)
        case removeAllUploads
        case presentMediaPicker(itemSelected: (ListItemKind) -> Void)
        case offerMediaUpgrade(SingleMediaUpgradeAlertConfiguration,
                               accepted: () -> Void,
                               declined: () -> Void)
        case showCallBubble(imageUrl: String?)
    }

    enum DelegateEvent {
        case pickMedia(ValueProvider<MediaPickerEvent>)
        case takeMedia(ValueProvider<MediaPickerEvent>)
        case pickFile(ValueProvider<FilePickerEvent>)
        case mediaUpgradeAccepted(offer: MediaUpgradeOffer,
                                  answer: AnswerWithSuccessBlock)
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
    private let call: ValueProvider<Call?>
    private var unreadMessages: UnreadMessagesHandler!
    private let showsCallBubble: Bool
    private let storage = ChatStorage()
    private let uploader = FileUploader()
    private let downloader = FileDownloader<ChatEngagementFile>()
    private var messageText = "" {
        didSet {
            validateMessage()
            sendMessagePreview(messageText)
            action?(.setMessageText(messageText))
        }
    }

    init(interactor: Interactor,
         alertConfiguration: AlertConfiguration,
         call: ValueProvider<Call?>,
         unreadMessages: ValueProvider<Int>,
         showsCallBubble: Bool,
         isWindowVisible: ValueProvider<Bool>,
         startAction: StartAction) {
        self.call = call
        self.showsCallBubble = showsCallBubble
        self.startAction = startAction
        super.init(interactor: interactor, alertConfiguration: alertConfiguration)
        self.unreadMessages = UnreadMessagesHandler(
            unreadMessages: unreadMessages,
            isWindowVisible: isWindowVisible,
            isViewVisible: isViewActive
        )
        self.call.addObserver(self) { call, _ in
            self.onCall(call)
        }
        self.uploader.state.addObserver(self) { state, _ in
            self.onUploaderStateChanged(state)
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
        case .removeUploadTapped(let index):
            removeFile(at: index)
        case .pickMediaTapped:
            presentMediaPicker()
        case .callBubbleTapped:
            delegate?(.call)
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
        appendItem(item,
                   to: queueOperatorSection,
                   animated: false)
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
            action?(.showEndButton)
            loadHistory()
        default:
            break
        }
    }

    private func appendItem(_ item: ChatItem,
                            to section: Section<ChatItem>,
                            animated: Bool) {
        appendItems([item],
                    to: section,
                    animated: animated)
    }

    private func appendItems(_ items: [ChatItem],
                             to section: Section<ChatItem>,
                             animated: Bool) {
        section.append(items)
        action?(.appendRows(items.count,
                            to: section.index,
                            animated: animated))
    }

    private func setItems(_ items: [ChatItem],
                          to section: Section<ChatItem>) {
        section.set(items)
        action?(.refreshAll)
    }

    private func replace(_ outgoingMessage: OutgoingMessage,
                         with message: Message,
                         in section: Section<ChatItem>) {
        guard let index = section.items
                .enumerated()
                .first(where: {
                    guard case let .outgoingMessage(message) = $0.element.kind else { return false }
                    return message.id == outgoingMessage.id
                })?.offset
        else { return }

        let status = Strings.Message.Status.delivered
        let message = ChatMessage(with: message)
        let item = ChatItem(kind: .visitorMessage(message, status: status))
        section.replaceItem(at: index, with: item)
        action?(.refreshRow(index, in: section.index, animated: false))
    }

    private func loadHistory() {
        let messages = storage.messages(forQueue: interactor.queueID)
        let items = messages.compactMap({ ChatItem(with: $0) })
        historySection.set(items)
        action?(.refreshSection(historySection.index))
        action?(.scrollToBottom(animated: true))
    }

    private func offerMediaUpgrade(_ offer: MediaUpgradeOffer, answer: @escaping AnswerWithSuccessBlock) {
        switch offer.type {
        case .audio:
            offerMediaUpgrade(with: alertConfiguration.audioUpgrade,
                              offer: offer,
                              answer: answer)
        case .video:
            let configuration = offer.direction == .oneWay
                ? alertConfiguration.oneWayVideoUpgrade
                : alertConfiguration.twoWayVideoUpgrade
            offerMediaUpgrade(with: configuration,
                              offer: offer,
                              answer: answer)
        default:
            break
        }
    }

    private func offerMediaUpgrade(with configuration: SingleMediaUpgradeAlertConfiguration,
                                   offer: MediaUpgradeOffer,
                                   answer: @escaping AnswerWithSuccessBlock) {
        guard isViewActive.value else { return }
        let operatorName = interactor.engagedOperator?.firstName
        let onAccepted = {
            self.delegate?(.mediaUpgradeAccepted(offer: offer, answer: answer))
            self.showCallBubble()
        }
        action?(.offerMediaUpgrade(configuration.withOperatorName(operatorName),
                                   accepted: { onAccepted() },
                                   declined: { answer(false, nil) }))
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

extension ChatViewModel {
    private func sendMessagePreview(_ message: String) {
        interactor.sendMessagePreview(message)
    }

    private func sendMessage() {
        guard validateMessage() else { return }

        let attachment = uploader.attachment
        let files = uploader.localFiles
        let outgoingMessage = OutgoingMessage(
            content: messageText,
            files: files
        )
        let item = ChatItem(with: outgoingMessage)
        appendItem(item, to: messagesSection, animated: true)
        uploader.removeAllUploads()
        action?(.removeAllUploads)
        action?(.scrollToBottom(animated: true))

        interactor.send(messageText, attachment: attachment) { message in
            self.messageText = ""
            self.replace(outgoingMessage,
                         with: message,
                         in: self.messagesSection)
            self.action?(.scrollToBottom(animated: true))
        } failure: { _ in
            self.messageText = ""
            self.showAlert(with: self.alertConfiguration.unexpectedError,
                           dismissed: nil)
        }
    }

    @discardableResult
    private func validateMessage() -> Bool {
        guard uploader.state.value != .uploading else { return false }
        let canSendText = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let canSendAttachment = uploader.failedUploads.isEmpty && !uploader.succeededUploads.isEmpty
        let isValid = canSendText || canSendAttachment
        action?(.sendButtonHidden(!isValid))
        return isValid
    }

    private func receivedMessage(_ message: Message) {
        guard storage.isNewMessage(message) else { return }

        storage.storeMessage(message,
                             queueID: interactor.queueID,
                             operator: interactor.engagedOperator)
        unreadMessages.received(1)

        switch message.sender {
        case .operator:
            let message = ChatMessage(with: message,
                                      operator: interactor.engagedOperator)
            if let item = ChatItem(with: message) {
                appendItem(item, to: messagesSection, animated: true)
                action?(.scrollToBottom(animated: true))
                action?(.updateItemsUserImage(animated: true))
            }
        default:
            break
        }
    }

    private func messagesUpdated(_ messages: [Message]) {
        let newMessages = storage.newMessages(messages)
        unreadMessages.received(newMessages.count)

        if !newMessages.isEmpty {
            storage.storeMessages(newMessages,
                                  queueID: interactor.queueID,
                                  operator: interactor.engagedOperator)
            let newMessages = newMessages.map({ ChatMessage(with: $0) })
            let items = newMessages.compactMap({ ChatItem(with: $0) })
            setItems(items, to: messagesSection)
            action?(.scrollToBottom(animated: true))
        }
    }
}

extension ChatViewModel {
    private func presentMediaPicker() {
        let itemSelected = { (kind: ListItemKind) -> Void in
            let mediaProvider = ValueProvider<MediaPickerEvent>(with: .none)
            mediaProvider.addObserver(self) { event, _ in
                switch event {
                case .none, .cancelled:
                    break
                case .pickedMedia(let media):
                    self.mediaPicked(media)
                case .sourceNotAvailable:
                    self.showAlert(with: self.alertConfiguration.mediaSourceNotAvailable, dismissed: nil)
                case .noCameraPermission:
                    self.showSettingsAlert(with: self.alertConfiguration.cameraSettings)
                }
            }
            let fileProvider = ValueProvider<FilePickerEvent>(with: .none)
            fileProvider.addObserver(self) { event, _ in
                switch event {
                case .none, .cancelled:
                    break
                case .pickedFile(let url):
                    self.filePicked(url)
                }
            }
            switch kind {
            case .photoLibrary:
                self.delegate?(.pickMedia(mediaProvider))
            case .takePhoto:
                self.delegate?(.takeMedia(mediaProvider))
            case .browse:
                self.delegate?(.pickFile(fileProvider))
            }
        }
        action?(.presentMediaPicker(itemSelected: { itemSelected($0) }))
    }

    private func mediaPicked(_ media: PickedMedia) {
        switch media {
        case .image(let url):
            addFile(with: url)
        case .movie(let url):
            addFile(with: url)
        case .none:
            break
        }
    }

    private func filePicked(_ url: URL) {
        addFile(with: url)
    }

    private func addFile(with url: URL) {
        let upload = uploader.addUpload(with: url)
        action?(.addUpload(upload))
    }

    private func removeFile(at index: Int) {
        guard let upload = uploader.upload(at: index) else { return }
        uploader.removeUpload(upload)
        action?(.removeUpload(index))
    }

    private func onUploaderStateChanged(_ state: FileUploader.State) {
        validateMessage()
    }
}

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
            message.downloads = downloader.downloads(for: message.attachment?.files, autoDownload: .images)
            if shouldShowOperatorImage(for: row, in: section) {
                let imageUrl = message.operator?.pictureUrl
                let kind: ChatItem.Kind = .operatorMessage(message,
                                                           showsImage: true,
                                                           imageUrl: imageUrl)
                return ChatItem(kind: kind)
            }
            return item
        case .visitorMessage(let message, _):
            message.downloads = downloader.downloads(for: message.attachment?.files, autoDownload: .images)
            return item
        default:
            return item
        }
    }

    private func shouldShowOperatorImage(for row: Int, in section: Section<ChatItem>) -> Bool {
        guard case .operatorMessage = section[row].kind else { return false }
        let nextItem = section.item(after: row)
        return nextItem == nil || nextItem?.isOperatorMessage == false
    }
}

extension ChatViewModel {
    private func onCall(_ call: Call?) {
        guard let call = call else { return }

        let kindProvider = ValueProvider<CallKind>(with: call.kind.value)
        let durationProvider = ValueProvider<Int>(with: 0)
        let item = ChatItem(kind: .callUpgrade(kindProvider,
                                               durationProvider: durationProvider))
        appendItem(item, to: messagesSection, animated: true)
        action?(.scrollToBottom(animated: true))

        call.kind.addObserver(self) { kind, _ in
            kindProvider.value = kind
        }
        call.duration.addObserver(item) { duration, _ in
            durationProvider.value = duration
        }
    }

    private func showCallBubble() {
        let imageUrl = interactor.engagedOperator?.picture?.url
        action?(.showCallBubble(imageUrl: imageUrl))
    }
}
