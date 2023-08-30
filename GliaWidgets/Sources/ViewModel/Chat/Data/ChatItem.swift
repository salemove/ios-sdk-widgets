import Foundation

class ChatItem {
    var isOperatorMessage: Bool {
        switch kind {
        // CustomCard was added to be able to handle as regular operator message
        // in case when metadata can't be handled.
        case .operatorMessage,
                .choiceCard,
                .customCard,
                .systemMessage,
                .gvaResponseText,
                .gvaPersistentButton,
                .gvaQuickReply,
                .gvaGallery:
            return true
        default:
            return false
        }
    }

    let kind: Kind

    init(
        kind: Kind
    ) {
        self.kind = kind
    }

    init(
        with message: OutgoingMessage
    ) {
        kind = .outgoingMessage(message)
    }

    init?(
        with message: ChatMessage,
        isCustomCardSupported: Bool,
        fromHistory: Bool = false
    ) {
        switch message.sender {
        case .visitor:
            kind = .visitorMessage(message, status: nil)
        case .operator:
            switch message.cardType {
            case .choiceCard:
                kind = .choiceCard(message, showsImage: false, imageUrl: nil, isActive: !fromHistory)
            case .customCard:
                if isCustomCardSupported {
                    kind = .customCard(
                        message,
                        showsImage: false,
                        imageUrl: nil,
                        isActive: !fromHistory
                    )
                } else {
                    return nil
                }
            case let .gvaPersistenButton(button):
                kind = .gvaPersistentButton(message, persistenButton: button, showImage: false, imageUrl: message.operator?.pictureUrl)
            case let .gvaResponseText(text):
                kind = .gvaResponseText(message, responseText: text, showImage: false, imageUrl: message.operator?.pictureUrl)
            case let .gvaQuickReply(button):
                kind = .gvaQuickReply(message, quickReply: button, showImage: false, imageUrl: message.operator?.pictureUrl)
            case let .gvaGallery(gallery):
                kind = .gvaGallery(message, gallery: gallery, showImage: false, imageUrl: message.operator?.pictureUrl)
            case .none:
                kind = .operatorMessage(message, showsImage: false, imageUrl: message.operator?.pictureUrl)
            }
        case .system:
            kind = .systemMessage(message)
        case .omniguide, .unknown:
            return nil
        }
    }
}

extension ChatItem {
    enum Kind {
        case queueOperator
        case outgoingMessage(OutgoingMessage)
        case visitorMessage(ChatMessage, status: String?)
        case operatorMessage(ChatMessage, showsImage: Bool, imageUrl: String?)
        case choiceCard(ChatMessage, showsImage: Bool, imageUrl: String?, isActive: Bool)
        // showsImage and imageUrl were added to be able to handle as regular operator message
        // in case when metadata can't be handled
        case customCard(ChatMessage, showsImage: Bool, imageUrl: String?, isActive: Bool)
        case callUpgrade(ObservableValue<CallKind>, duration: ObservableValue<Int>)
        case operatorConnected(name: String?, imageUrl: String?)
        case transferring
        case unreadMessageDivider
        case systemMessage(ChatMessage)
        case gvaPersistentButton(ChatMessage, persistenButton: GvaButton, showImage: Bool, imageUrl: String?)
        case gvaResponseText(ChatMessage, responseText: GvaResponseText, showImage: Bool, imageUrl: String?)
        case gvaQuickReply(ChatMessage, quickReply: GvaButton, showImage: Bool, imageUrl: String?)
        case gvaGallery(ChatMessage, gallery: GvaGallery, showImage: Bool, imageUrl: String?)
    }
}
