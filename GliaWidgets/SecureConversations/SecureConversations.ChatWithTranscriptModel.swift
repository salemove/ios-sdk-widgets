import Foundation

enum SecureChatModel<Chat, Transcript> {
    case chat(Chat)
    case transcript(Transcript)
}

protocol CommonEngagementModel: AnyObject {
    var engagementAction: EngagementViewModel.ActionCallback? { get set }
    var engagementDelegate: EngagementViewModel.DelegateCallback? { get set }
    func event(_ event: EngagementViewModel.Event)
}

extension SecureChatModel where Chat: CommonEngagementModel, Transcript: CommonEngagementModel {
    var engagementModel: CommonEngagementModel {
        switch self {
        case let .chat(model):
            return model
        case let .transcript(model):
            return  model
        }
    }

    var engagementDelegate: EngagementViewModel.DelegateCallback? {
        get {
            engagementModel.engagementDelegate
        }

        set {
            engagementModel.engagementDelegate = newValue
        }
    }

    var engagementAction: EngagementViewModel.ActionCallback? {
        get {
            engagementModel.engagementAction
        }

        set {
            engagementModel.engagementAction = newValue
        }
    }

    func event(_ event: EngagementViewModel.Event) {
        engagementModel.event(event)
    }
}

extension SecureConversations.ChatWithTranscriptModel {
    typealias Action = Chat.Action
    typealias ActionCallback = (Action) -> Void
    typealias DelegateEvent = SecureChatModel<Chat.DelegateEvent, Transcript.DelegateEvent>
    typealias DelegateCallback = (DelegateEvent) -> Void
    typealias Event = Chat.Event

    var action: ActionCallback? {
        get {
            switch self {
            case let .chat(model):
                return model.action
            case let .transcript(model):
                return model.action
            }
        }

        set {
            switch self {
            case let .chat(model):
                model.action = newValue
            case let .transcript(model):
                model.action = newValue
            }
        }
    }

    var delegate: DelegateCallback? {
        get {
            switch self {
            case let .chat(model):
                return model.delegate.map { callback in { action in
                        switch action {
                        case let .chat(chatAction):
                            callback(chatAction)
                        case .transcript:
                            break
                        }
                    }
                }
            case let .transcript(model):
                return model.delegate.map { callback in { delegateEvent in
                        switch delegateEvent {
                        case .chat:
                            break
                        case let .transcript(delegateEvent):
                            callback(delegateEvent)
                        }
                    }
                }
            }
        }

        set {
            switch self {
            case let .chat(model):
                model.delegate = newValue.map { callback in { delegateEvent in
                        callback(.chat(delegateEvent))
                    }
                }
            case let .transcript(model):
                model.delegate = newValue.map { callback in { delegateEvent in
                        callback(.transcript(delegateEvent))
                    }
                }
            }
        }
    }

    var numberOfSections: Int {
        switch self {
        case let .chat(model):
            return model.numberOfSections
        case let .transcript(model):
            return model.numberOfSections
        }
    }

    func event(_ event: Event) {
        switch self {
        case let .chat(model):
            model.event(event)
        case let .transcript(model):
            model.event(event)
        }
    }

    func numberOfItems(in section: Int) -> Int {
        switch self {
        case let .chat(model):
            return model.numberOfItems(in: section)
        case let .transcript(model):
            return model.numberOfItems(in: section)
        }
    }

    func item(for row: Int, in section: Int) -> ChatItem {
        switch self {
        case let .chat(model):
            return model.item(for: row, in: section)
        case let .transcript(model):
            return model.item(for: row, in: section)
        }
    }

    static func replace(
            _ outgoingMessage: OutgoingMessage,
            uploads: [FileUpload],
            with message: CoreSdkClient.Message,
            in section: Section<ChatItem>,
            deliveredStatusText: String,
            downloader: FileDownloader,
            action: ActionCallback?
        ) {
            guard let index = section.items
                .enumerated()
                .first(where: {
                    guard case .outgoingMessage(let message) = $0.element.kind else { return false }
                    return message.id == outgoingMessage.id
                })?.offset
            else { return }

            var affectedRows = [Int]()

            // Remove previous "Delivered" statuses
            section.items
                .enumerated()
                .forEach { index, element in
                    if case .visitorMessage(let message, let status) = element.kind,
                       status == deliveredStatusText {
                        let chatItem = ChatItem(kind: .visitorMessage(message, status: nil))
                        section.replaceItem(at: index, with: chatItem)
                        affectedRows.append(index)
                    }
                }

            let deliveredMessage = ChatMessage(with: message)
            let kind = ChatItem.Kind.visitorMessage(
                deliveredMessage,
                status: deliveredStatusText
            )
            let item = ChatItem(kind: kind)
            downloader.addDownloads(for: deliveredMessage.attachment?.files)
            section.replaceItem(at: index, with: item)
            affectedRows.append(index)
            action?(.refreshRows(affectedRows, in: section.index, animated: false))
        }

    static func item(
            for row: Int,
            in section: Int,
            from sections: [Section<ChatItem>],
            downloader: FileDownloader
        ) -> ChatItem {
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

            case .customCard(let message, _, _, let isActive):
                let imageUrl = message.operator?.pictureUrl
                let shouldShowImage = shouldShowOperatorImage(for: row, in: section)
                let kind: ChatItem.Kind = .customCard(
                    message,
                    showsImage: shouldShowImage,
                    imageUrl: imageUrl,
                    isActive: isActive
                )
                return ChatItem(kind: kind)
            default:
                return item
            }
        }

        static private func shouldShowOperatorImage(
            for row: Int,
            in section: Section<ChatItem>
        ) -> Bool {
            guard section[row].isOperatorMessage else { return false }
            let nextItem = section.item(after: row)
            return nextItem == nil || nextItem?.isOperatorMessage == false
        }

}

extension SecureConversations {
    final class TranscriptModel: CommonEngagementModel {
        typealias ActionCallback = (Action) -> Void
        typealias DelegateCallback = (DelegateEvent) -> Void
        typealias Action = ChatViewModel.Action

        static let unavailableMessageCenterAlertAccIdentidier = "unavailable_message_center_alert_identifier"
        static let markUnreadMessagesDelaySeconds = 6

        enum DelegateEvent {
            case showFile(LocalFile)
            case openLink(URL)
            case showAlertAsView(
                MessageAlertConfiguration,
                accessibilityIdentifier: String?,
                dismissed: (() -> Void)?
            )
            case pickMedia(ObservableValue<MediaPickerEvent>)
            case takeMedia(ObservableValue<MediaPickerEvent>)
            case pickFile(ObservableValue<FilePickerEvent>)
            case upgradeToChatEngagement(TranscriptModel)
        }

        typealias Event = ChatViewModel.Event

        static let messageTextLimit = WelcomeViewModel.messageTextLimit
        static let maximumUploads = WelcomeViewModel.maximumUploads

        var action: ActionCallback?
        var delegate: DelegateCallback?

        var engagementAction: EngagementViewModel.ActionCallback?
        var engagementDelegate: EngagementViewModel.DelegateCallback?

        private let downloader: FileDownloader
        let fileUploadListModel: SecureConversations.FileUploadListViewModel

        private var messageText = "" {
            didSet {
                validateMessage()
                action?(.setMessageText(messageText))
            }
        }

        private let isCustomCardSupported: Bool

        private (set) var isViewLoaded: Bool = false

        var environment: Environment
        var availability: Availability
        var isSecureConversationsAvailable: Bool = true {
            didSet {
                // Hide text field in MOB-1882
                print("availability has changed")
            }
        }

        var siteConfiguration: CoreSdkClient.Site?

        var mediaPickerButtonVisibility: MediaPickerButtonVisibility {
            guard let site = siteConfiguration else { return .disabled }
            guard site.allowedFileSenders.visitor else { return .disabled }
            return .enabled(.secureMessaging)
        }

        let sections = [
            Section<ChatItem>(0),
            Section<ChatItem>(1),
            Section<ChatItem>(2),
            Section<ChatItem>(3)
        ]

        var historySection: Section<ChatItem> { sections[0] }
        var pendingSection: Section<ChatItem> { sections[1] }
        let deliveredStatusText: String

        var numberOfSections: Int {
            sections.count
        }

        let transcriptMessageLoader: SecureConversations.MessagesWithUnreadCountLoader

        init(
            isCustomCardSupported: Bool,
            environment: Environment,
            availability: Availability,
            deliveredStatusText: String
        ) {
            self.isCustomCardSupported = isCustomCardSupported
            self.environment = environment
            self.downloader = FileDownloader(
                environment: .init(
                    fetchFile: .fromSecureMessaging(environment.fetchFile),
                    fileManager: environment.fileManager,
                    data: environment.data,
                    date: environment.date,
                    gcd: environment.gcd,
                    localFileThumbnailQueue: environment.localFileThumbnailQueue,
                    uiImage: environment.uiImage,
                    createFileDownload: environment.createFileDownload
                )
            )

            self.availability = availability
            self.deliveredStatusText = deliveredStatusText

            let uploader = FileUploader(
                maximumUploads: Self.maximumUploads,
                environment: .init(
                    uploadFile: .toSecureMessaging(environment.secureUploadFile),
                    fileManager: environment.fileManager,
                    data: environment.data,
                    date: environment.date,
                    gcd: environment.gcd,
                    localFileThumbnailQueue: environment.localFileThumbnailQueue,
                    uiImage: environment.uiImage,
                    uuid: environment.uuid
                )
            )

            self.fileUploadListModel = environment.createFileUploadListModel(
                .init(
                    uploader: uploader,
                    style: .chat(environment.fileUploadListStyle),
                    uiApplication: environment.uiApplication
                )
            )

            self.transcriptMessageLoader = SecureConversations.MessagesWithUnreadCountLoader(
                environment: .init(
                    getSecureUnreadMessageCount: environment.getSecureUnreadMessageCount,
                    fetchChatHistory: environment.fetchChatHistory,
                    scheduler: environment.messagesWithUnreadCountLoaderScheduler
                )
            )

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
            availability.checkSecureConversationsAvailability { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(.available):
                    self.isSecureConversationsAvailable = true
                case .failure, .success(.unavailable(.emptyQueue)):
                    self.isSecureConversationsAvailable = false
                    let configuration = self.environment.alertConfiguration.unavailableMessageCenter
                    self.reportMessageCenterUnavailable(configuration: configuration)
                case .success(.unavailable(.unauthenticated)):
                    let configuration = self.environment.alertConfiguration.unavailableMessageCenterForBeingUnauthenticated
                    self.reportMessageCenterUnavailable(configuration: configuration)
                }
            }
		}

        func reportMessageCenterUnavailable(configuration: MessageAlertConfiguration) {
            self.delegate?(
                .showAlertAsView(
                    configuration,
                    accessibilityIdentifier: Self.unavailableMessageCenterAlertAccIdentidier,
                    dismissed: nil
                )
            )
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
                // Not supported for transcript.
                break
            case .fileTapped(let file):
                fileTapped(file)
            case .downloadTapped(let download):
                downloadTapped(download)
            case .choiceOptionSelected:
                // Not supported for transcript.
                break
            case .chatScrolled:
                // Not supported for transcript.
                break
            case .linkTapped(let url):
                linkTapped(url)
            case .customCardOptionSelected:
                // Not supported for transcript.
                break
            }
        }

        func start() {
            fetchSiteConfigurations()
            loadHistory { _ in }
        }

        deinit {
            environment.interactor.removeObserver(self)
        }
    }
}

// MARK: Input validation
extension SecureConversations.TranscriptModel {
    @discardableResult
    private func validateMessage() -> Bool {
        let canSendAttachments =
        fileUploadListModel.failedUploads.isEmpty &&
        fileUploadListModel.activeUploads.isEmpty && !fileUploadListModel.isLimitReached

        guard canSendAttachments else { return false }

        let canSendText = !messageText.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty && messageText.count <= Self.messageTextLimit
        let hasAttachments = !fileUploadListModel.succeededUploads.isEmpty

        let isValid = canSendText || hasAttachments
        action?(.sendButtonHidden(!isValid))
        return isValid
    }
}

// MARK: Message management
extension SecureConversations.TranscriptModel {
    private func sendMessage() {
        guard validateMessage() else { return }

        let uploads = fileUploadListModel.succeededUploads
        let localFiles = uploads.map(\.localFile)

        let outgoingMessage = OutgoingMessage(
            content: messageText,
            files: localFiles
        )
        appendItem(
            .init(kind: .outgoingMessage(outgoingMessage)),
            to: pendingSection,
            animated: true
        )

       _ = environment.sendSecureMessage(
            messageText,
            fileUploadListModel.attachment,
            environment.queueIds
       ) { [weak self] result in
           guard let self = self else { return }
           switch result {
           case let .success(message):
               self.replace(
                outgoingMessage,
                uploads: uploads,
                with: message,
                in: self.pendingSection
               )
           case .failure:
               self.showAlert(with: self.environment.alertConfiguration.unexpectedError)
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
        switch url.scheme?.lowercased() {
        case "tel",
            "mailto":
            guard
                environment.uiApplication.canOpenURL(url)
            else { return }

            environment.uiApplication.open(url)

        case "http",
            "https":
            delegate?(.openLink(url))

        default:
            return
        }
    }
}

// MARK: Handling of file-picker
extension SecureConversations.TranscriptModel {
    private func presentMediaPicker() {
        let itemSelected = { [weak self] (kind: AttachmentSourceItemKind) -> Void in
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
                    self.showAlert(
                        with: self.environment.alertConfiguration.mediaSourceNotAvailable,
                        dismissed: nil
                    )
                case .noCameraPermission:
                    self.showSettingsAlert(with: self.environment.alertConfiguration.cameraSettings)
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

// MARK: Handling of alerts
extension SecureConversations.TranscriptModel {
    func showSettingsAlert(
        with conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)? = nil
    ) {
        engagementAction?(.showSettingsAlert(conf, cancelled: cancelled))
    }

    func showAlert(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String? = nil,
        dismissed: (() -> Void)? = nil
    ) {
        engagementAction?(
            .showAlert(
                conf,
                accessibilityIdentifier: accessibilityIdentifier,
                dismissed: dismissed
            )
        )
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
                self.action?(.setAttachmentButtonVisibility(self.mediaPickerButtonVisibility))
            case .failure:
                self.showAlert(
                    with: self.environment.alertConfiguration.unexpectedError,
                    dismissed: nil
                )
            }
        }
    }
}

extension SecureConversations {
    typealias ChatWithTranscriptModel = SecureChatModel<ChatViewModel, TranscriptModel>
}

extension SecureConversations.TranscriptModel {
    struct Environment {
        var fetchFile: CoreSdkClient.DownloadSecureFile
        var fileManager: FoundationBased.FileManager
        var data: FoundationBased.Data
        var date: () -> Date
        var gcd: GCD
        var localFileThumbnailQueue: FoundationBased.OperationQueue
        var uiImage: UIKitBased.UIImage
        var createFileDownload: FileDownloader.CreateFileDownload
        var loadChatMessagesFromHistory: () -> Bool
        var fetchChatHistory: CoreSdkClient.FetchChatHistory
        var uiApplication: UIKitBased.UIApplication
        var sendSecureMessage: CoreSdkClient.SendSecureMessage
        var queueIds: [String]
        var listQueues: CoreSdkClient.ListQueues
        var alertConfiguration: AlertConfiguration
        var createFileUploadListModel: SecureConversations.FileUploadListViewModel.Create
        var uuid: () -> UUID
        var secureUploadFile: CoreSdkClient.SecureConversationsUploadFile
        var fileUploadListStyle: FileUploadListStyle
        var fetchSiteConfigurations: CoreSdkClient.FetchSiteConfigurations
        var getSecureUnreadMessageCount: CoreSdkClient.GetSecureUnreadMessageCount
        var messagesWithUnreadCountLoaderScheduler: CoreSdkClient.ReactiveSwift.DateScheduler
        var secureMarkMessagesAsRead: CoreSdkClient.SecureMarkMessagesAsRead
        var interactor: Interactor
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

                self.historySection.set(itemsWithDivider)
                self.action?(.refreshSection(self.historySection.index))
                self.action?(.scrollToBottom(animated: false))
                completion(messagesWithUnreadCount.messages)
                if messagesWithUnreadCount.unreadCount > 0 {
                    self.markMessagesAsRead()
                }

                switch self.environment.interactor.state {
                // If engagement has been started
                // we signal perform upgrade.
                case .engaged:
                    self.delegate?(.upgradeToChatEngagement(self))
                case .none, .enqueueing, .ended, .enqueued:
                    self.environment.interactor.addObserver(self) { [weak self] event in
                        self?.handleInteractorEvent(event)
                    }
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
        default:
            break
        }
    }

    func markMessagesAsRead() {
        environment.gcd.mainQueue.asyncAfterDeadline(.now() + .seconds(Self.markUnreadMessagesDelaySeconds)) { [weak self] in
            _ = self?.environment.secureMarkMessagesAsRead { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.historySection.removeAll(where: {
                        if case .unreadMessageDivider = $0.kind {
                            return true
                        }

                        return false
                    })
                    self.action?(.refreshSection(self.historySection.index, animated: true))
                case .failure:
                    break
                }
            }
        }
    }
}

// MARK: Hashable
extension SecureConversations.TranscriptModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: SecureConversations.TranscriptModel, rhs: SecureConversations.TranscriptModel) -> Bool {
        lhs === rhs
    }
}

extension SecureConversations.TranscriptModel {
    static func dividedChatItemsForUnreadCount(
        chatItems: [ChatItem],
        unreadCount: Int,
        divider: ChatItem
    ) -> [ChatItem] {
        var tail: [ChatItem] = []
        var unreadCount = unreadCount
        var head = chatItems
        var dividerIndex: Int?
        while unreadCount > 0 {
            // Remove messages from the end of list.
            // In case list has ended, that means unread count
            // is larger than list size, so we break to prevent
            // infinite loop.
            guard let item = head.popLast() else {
                break
            }
            // Removed items are placed into separate list,
            // to be later combined with initial one.
            tail.insert(item, at: 0)

            // We treat only operator messages
            // eligible to be counted as unread.
            if item.isOperatorMessage {
                // Update divider insertion index with
                // next relevant one.
                dividerIndex = head.endIndex
                unreadCount -= 1
            }
        }

        // At this point we have finished search for insertion
        // index for divider, so we combine two lists together.
        var result = head + tail

        // Make sure that divider index is within safe bounds
        // before performing the insertion.
        if let dividerIndex, dividerIndex <= result.endIndex {
            result.insert(divider, at: dividerIndex)
        }

        return result
    }
}
