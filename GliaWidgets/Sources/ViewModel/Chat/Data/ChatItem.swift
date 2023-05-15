import Foundation

class ChatItem {
    var isOperatorMessage: Bool {
        switch kind {
        // CustomCard was added to be able to handle as regular operator message
        // in case when metadata can't be handled.
        case .operatorMessage, .choiceCard, .customCard, .systemMessage:
            return true
        default:
            return false
        }
    }

    var id: String? {
        switch kind {
        case .operatorMessage(let chatMessage, _, _):
            return chatMessage.id
        case .outgoingMessage(let outgoingMessage):
            return outgoingMessage.id
        case .visitorMessage(let chatMessage, _):
            return chatMessage.id
        case .choiceCard(let chatMessage, _, _, _):
            return chatMessage.id
        case .customCard(let chatMessage, _, _, _):
            return chatMessage.id
        case .systemMessage(let chatMessage):
            return chatMessage.id
        case .callUpgrade, .queueOperator, .operatorConnected, .transferring, .unreadMessageDivider:
            return nil
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
        case .operator where message.isCustomCard && isCustomCardSupported:
            kind = .customCard(
                message,
                showsImage: false,
                imageUrl: nil,
                isActive: !fromHistory
            )
        case .operator:
            kind = message.isChoiceCard ?
                .choiceCard(message, showsImage: false, imageUrl: nil, isActive: !fromHistory) :
                .operatorMessage(message, showsImage: false, imageUrl: message.operator?.pictureUrl)
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
    }
}

extension ChatItem: Equatable {
    static func == (lhs: ChatItem, rhs: ChatItem) -> Bool {
        guard let lhsId = lhs.id, let rhsId = rhs.id else { return false }

        switch (lhs.kind, rhs.kind) {
        case (.operatorMessage, .operatorMessage),
            (.outgoingMessage, .outgoingMessage),
            (.visitorMessage, .visitorMessage),
            (.choiceCard, .choiceCard),
            (.customCard, .customCard),
            (.systemMessage, .systemMessage):
            return lhsId == rhsId
        default: return false
        }
    }
}
