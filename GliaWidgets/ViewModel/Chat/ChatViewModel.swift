import Foundation

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
        case offerMediaUpgrade(
            SingleMediaUpgradeAlertConfiguration,
            accepted: () -> Void,
            declined: () -> Void
        )
        case showCallBubble(imageUrl: String?)
        case updateUnreadMessageIndicator(itemCount: Int)
        case setOperatorTypingIndicatorIsHiddenTo(Bool, _ isChatScrolledToBottom: Bool)
    }

    enum DelegateEvent {
        case pickMedia(ObservableValue<MediaPickerEvent>)
        case takeMedia(ObservableValue<MediaPickerEvent>)
        case pickFile(ObservableValue<FilePickerEvent>)
        case mediaUpgradeAccepted(
            offer: CoreSdkClient.MediaUpgradeOffer,
            answer: CoreSdkClient.AnswerWithSuccessBlock
        )
        case showFile(LocalFile)
        case call
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
    private let call: ObservableValue<Call?>
    private var unreadMessages: UnreadMessagesHandler!
    private let screenShareHandler: ScreenShareHandler
    private let isChatScrolledToBottom = ObservableValue<Bool>(with: true)
    private let showsCallBubble: Bool
    private let uploader: FileUploader
    private let downloader: FileDownloader
    private var messageText = "" {
        didSet {
            validateMessage()
            sendMessagePreview(messageText)
            action?(.setMessageText(messageText))
        }
    }

    private var pendingMessages: [OutgoingMessage] = []
    private var isViewLoaded: Bool = false
    private var environment: Environment

    init(
        interactor: Interactor,
        alertConfiguration: AlertConfiguration,
        screenShareHandler: ScreenShareHandler,
        call: ObservableValue<Call?>,
        unreadMessages: ObservableValue<Int>,
        showsCallBubble: Bool,
        isWindowVisible: ObservableValue<Bool>,
        startAction: StartAction,
        environment: Environment
    ) {
        self.call = call
        self.showsCallBubble = showsCallBubble
        self.startAction = startAction
        self.screenShareHandler = screenShareHandler
        self.environment = environment
        self.uploader = FileUploader(
            maximumUploads: 25,
            environment: .init(
                uploadFileToEngagement: environment.uploadFileToEngagement,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date,
                uuid: environment.uuid
            )
        )
        self.downloader = FileDownloader(
            environment: .init(
                fetchFile: environment.fetchFile,
                fileManager: environment.fileManager,
                data: environment.data,
                date: environment.date

            )
        )
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

        if case .startEngagement = startAction, environment.chatStorage.isEmpty() {
            let item = ChatItem(kind: .queueOperator)

            appendItem(
                item,
                to: queueOperatorSection,
                animated: false
            )

            enqueue(mediaType: .text)
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

            switch screenShareHandler.status.value {
            case .started:
                engagementAction?(.showEndScreenShareButton)
            case .stopped:
                engagementAction?(.showEndButton)
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
                    guard let self = self else { return }

                    self.showAlert(
                        with: self.alertConfiguration.unexpectedError,
                        dismissed: nil
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
        case .receivedMessage(let message):
            receivedMessage(message)
        case .messagesUpdated(let messages):
            messagesUpdated(messages)
        case .upgradeOffer(let offer, answer: let answer):
            offerMediaUpgrade(offer, answer: answer)
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
        let messages = environment.chatStorage.messages(interactor.queueID)
        let items = messages.compactMap { ChatItem(with: $0, fromHistory: true) }
        historySection.set(items)
        action?(.refreshSection(historySection.index))
        action?(.scrollToBottom(animated: false))
    }
}

// MARK: Media Upgrade

extension ChatViewModel {
    private func offerMediaUpgrade(
        _ offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
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
        offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
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
                guard let self = self else { return }

                self.showAlert(
                    with: self.alertConfiguration.unexpectedError,
                    dismissed: nil
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
        with message: CoreSdkClient.Message,
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

    private func receivedMessage(_ message: CoreSdkClient.Message) {
        guard environment.chatStorage.isNewMessage(message) else { return }

        environment.chatStorage.storeMessage(
            message,
            interactor.queueID,
            interactor.engagedOperator
        )

        switch message.sender {
        case .operator:
            let message = ChatMessage(
                with: message,
                operator: interactor.engagedOperator
            )
            if let item = ChatItem(with: message) {
                unreadMessages.received(1)

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

    private func messagesUpdated(_ messages: [CoreSdkClient.Message]) {
        let newMessages = environment.chatStorage.newMessages(messages)
        unreadMessages.received(newMessages.count)

        if !newMessages.isEmpty {
            environment.chatStorage.storeMessages(
                newMessages,
                interactor.queueID,
                interactor.engagedOperator
            )
            let newMessages = newMessages.map { ChatMessage(with: $0) }
            let items = newMessages.compactMap { ChatItem(with: $0) }
            setItems(items, to: messagesSection)
            action?(.scrollToBottom(animated: true))
        }
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
        let itemSelected = { (kind: AtttachmentSourceItemKind) -> Void in
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

    private func linkTapped(_ url: URL) {
        delegate?(.openLink(url))
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
        environment.sendSelectedOptionValue(value) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                guard
                    let selection = message.attachment?.selectedOption
                else { return }

                self.respond(to: messageId, with: selection)

            case .failure:
                self.showAlert(
                    with: self.alertConfiguration.unexpectedError,
                    dismissed: nil
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
        environment.chatStorage.updateMessage(message)

        action?(.refreshRow(index, in: messagesSection.index, animated: true))
        action?(.setChoiceCardInputModeEnabled(false))
    }
}

extension ChatViewModel {
    struct Environment {
        var chatStorage: Glia.Environment.ChatStorage
        var fetchFile: CoreSdkClient.FetchFile
        var sendSelectedOptionValue: CoreSdkClient.SendSelectedOptionValue
        var uploadFileToEngagement: CoreSdkClient.UploadFileToEngagement
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var uuid: () -> UUID
    }
}
