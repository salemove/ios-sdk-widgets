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
}

extension SecureConversations {
    final class TranscriptModel: CommonEngagementModel {
        typealias ActionCallback = (Action) -> Void
        typealias DelegateCallback = (DelegateEvent) -> Void
        typealias Action = ChatViewModel.Action

        enum DelegateEvent {
            case showFile(LocalFile)
            case openLink(URL)
        }

        typealias Event = ChatViewModel.Event

        var action: ActionCallback?
        var delegate: DelegateCallback?

        var engagementAction: EngagementViewModel.ActionCallback?
        var engagementDelegate: EngagementViewModel.DelegateCallback?

        private let downloader: FileDownloader

        private var messageText = "" {
            didSet {
                validateMessage()
                action?(.setMessageText(messageText))
            }
        }

        private let isCustomCardSupported: Bool

        private var isViewLoaded: Bool = false

        private let environment: Environment

        private let sections = [
            Section<ChatItem>(0)
        ]

        var historySection: Section<ChatItem> { sections[0] }

        var numberOfSections: Int {
            sections.count
        }

        init(
            isCustomCardSupported: Bool,
            environment: Environment
        ) {
            self.isCustomCardSupported = isCustomCardSupported
            self.environment = environment
            self.downloader = FileDownloader(
                environment: .init(
                    fetchFile: environment.fetchFile,
                    fileManager: environment.fileManager,
                    data: environment.data,
                    date: environment.date,
                    gcd: environment.gcd,
                    localFileThumbnailQueue: environment.localFileThumbnailQueue,
                    uiImage: environment.uiImage,
                    createFileDownload: environment.createFileDownload
                )
            )
        }

        // TODO: Common with chat model, should it be unified?
        func numberOfItems(in section: Int) -> Int {
            sections[section].itemCount
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

        private func shouldShowOperatorImage(
            for row: Int,
            in section: Section<ChatItem>
        ) -> Bool {
            guard section[row].isOperatorMessage else { return false }
            let nextItem = section.item(after: row)
            return nextItem == nil || nextItem?.isOperatorMessage == false
        }

        func event(_ event: EngagementViewModel.Event) {
            // Not used for transcript.
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
            case .removeUploadTapped:
                // TODO: MOB-1742
                break
            case .pickMediaTapped:
                // TODO: MOB-1742
                break
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
            loadHistory { _ in }
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

        @discardableResult
        private func validateMessage() -> Bool {
            let canSendText = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            // TODO: File uploading validation MOB-1742
            action?(.sendButtonHidden(!canSendText))
            return canSendText
        }

        private func sendMessage() {
            guard validateMessage() else { return }

           _ = environment.sendSecureMessage(
                messageText,
                nil, // TODO: File uploading MOB-1742
                environment.queueIds
           ) { [weak self] result in
               switch result {
               case .success:
                   self?.messageText = ""
                   // TODO: MOB-1738
               case .failure:
                   // TODO: MOB-1874
                   break
               }
           }
        }
    }
}

extension SecureConversations {
    typealias ChatWithTranscriptModel = SecureChatModel<ChatViewModel, TranscriptModel>
}

extension SecureConversations.TranscriptModel {
    struct Environment {
        var fetchFile: CoreSdkClient.FetchFile
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
    }
}

// MARK: History

extension SecureConversations.TranscriptModel {
    private func loadHistory(_ completion: @escaping ([ChatMessage]) -> Void) {
        environment.fetchChatHistory { [weak self] result in
            guard let self = self else { return }
            let messages = (try? result.get()) ?? []
            let items = messages.compactMap {
                ChatItem(
                    with: $0,
                    isCustomCardSupported: self.isCustomCardSupported,
                    fromHistory: self.environment.loadChatMessagesFromHistory()
                )
            }
            self.historySection.set(items)
            self.action?(.refreshSection(self.historySection.index))
            self.action?(.scrollToBottom(animated: false))
            completion(messages)
        }
    }
}
