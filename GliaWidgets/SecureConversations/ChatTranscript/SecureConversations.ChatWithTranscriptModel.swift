import Foundation
import Combine

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

    var isSendMessageAvailable: Bool {
        switch self {
        case .chat:
            true
        case let .transcript(model):
            model.isSecureConversationsAvailable
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

    var entryWidget: EntryWidget? {
        switch self {
        case let .chat(model):
            return model.entryWidget
        case let .transcript(model):
            return model.entryWidget
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
                    guard case .outgoingMessage(let message, _) = $0.element.kind else { return false }
                    return message.payload.messageId == outgoingMessage.payload.messageId
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

    static func replace(
            _ messageId: ChatMessage.MessageId,
            with message: CoreSdkClient.Message,
            in section: Section<ChatItem>,
            deliveredStatusText: String,
            downloader: FileDownloader,
            action: ActionCallback?
        ) {
            guard let index = section.items
                .enumerated()
                .first(where: { _, element in
                    Self.chatItemMatchesMessageId(
                        chatItem: element,
                        messageId: messageId
                    )
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

        static func chatItemMatchesMessageId(
            chatItem: ChatItem,
            messageId: ChatMessage.MessageId
        ) -> Bool {
            switch chatItem.kind {
            case let .outgoingMessage(outgoingMessage, _):
                return outgoingMessage.payload.messageId.rawValue.uppercased() == messageId.uppercased()
            case let .visitorMessage(message, _):
                return message.id.uppercased() == messageId.uppercased()
            case .queueOperator,
                    .operatorMessage,
                    .choiceCard,
                    .customCard,
                    .callUpgrade,
                    .operatorConnected,
                    .transferring,
                    .unreadMessageDivider,
                    .systemMessage,
                    .gvaPersistentButton,
                    .gvaResponseText,
                    .gvaQuickReply,
                    .gvaGallery:
                return false
            }
        }

    // swiftlint:disable function_body_length
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
        case let .gvaResponseText(message, responseText, _, imageUrl):
            let kind: ChatItem.Kind = .gvaResponseText(
                message,
                responseText: responseText,
                showImage: shouldShowOperatorImage(for: row, in: section),
                imageUrl: imageUrl
            )
            return ChatItem(kind: kind)
        case let .gvaPersistentButton(message, persistenButton, _, imageUrl):
            let kind: ChatItem.Kind = .gvaPersistentButton(
                message,
                persistenButton: persistenButton,
                showImage: shouldShowOperatorImage(for: row, in: section),
                imageUrl: imageUrl
            )
            return ChatItem(kind: kind)
        case let .gvaQuickReply(message, quickReply, _, imageUrl):
            let kind: ChatItem.Kind = .gvaQuickReply(
                message,
                quickReply: quickReply,
                showImage: shouldShowOperatorImage(for: row, in: section),
                imageUrl: imageUrl
            )
            return ChatItem(kind: kind)
        case let .gvaGallery(message, gallery, _, imageUrl):
            let kind: ChatItem.Kind = .gvaGallery(
                message,
                gallery: gallery,
                showImage: shouldShowOperatorImage(for: row, in: section),
                imageUrl: imageUrl
            )
            return ChatItem(kind: kind)
        default:
            return item
        }
    }
    // swiftlint:enable function_body_length

    static func markMessageAsFailed(
        _ outgoingMessage: OutgoingMessage,
        in section: Section<ChatItem>,
        message: String,
        action: ActionCallback?
    ) {
        guard let index = section.items
            .enumerated()
            .first(where: { _, element in
                Self.chatItemMatchesMessageId(
                    chatItem: element,
                    messageId: outgoingMessage.payload.messageId.rawValue
                )
            })?.offset
        else { return }

        let item = ChatItem(kind: .outgoingMessage(
            outgoingMessage,
            error: message
        ))
        section.replaceItem(at: index, with: item)
        action?(.refreshRows([index], in: section.index, animated: false))
    }

    static func removeMessage(
        _ outgoingMessage: OutgoingMessage,
        in section: Section<ChatItem>,
        action: ActionCallback?
    ) {
        guard let index = section.items
            .enumerated()
            .first(where: { _, element in
                Self.chatItemMatchesMessageId(
                    chatItem: element,
                    messageId: outgoingMessage.payload.messageId.rawValue
                )
            })?.offset
        else { return }

        section.removeItem(at: index)
        action?(.deleteRows([index], in: section.index, animated: true))
    }

    static private func shouldShowOperatorImage(
        for row: Int,
        in section: Section<ChatItem>
    ) -> Bool {
        guard section[row].isOperatorMessage else { return false }
        let nextItem = section.item(after: row)
        return nextItem == nil || nextItem?.isOperatorMessage == false
    }

    static func makeEntryWidgetConfiguration(
        with mediaTypeSelected: Command<EntryWidget.MediaTypeItem>?,
        mediaTypeItemsStyle: EntryWidgetStyle.MediaTypeItemsStyle?
    ) -> EntryWidget.Configuration {
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
            mediaTypeSelected: mediaTypeSelected,
            mediaTypeItemsStyle: mediaTypeItemsStyle
        )
    }
}

extension SecureConversations {
    typealias ChatWithTranscriptModel = SecureChatModel<ChatViewModel, TranscriptModel>
}

extension SecureConversations.ChatWithTranscriptModel {
    var environment: Environment {
        switch self {
        case let .chat(model):
            return .init(log: model.environment.log)
        case let .transcript(model):
            return .init(log: model.environment.log)
        }
    }

    struct Environment {
        var log: CoreSdkClient.Logger
    }
}
