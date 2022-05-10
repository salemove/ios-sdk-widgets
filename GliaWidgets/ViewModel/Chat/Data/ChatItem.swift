import Foundation

class ChatItem {
    var isOperatorMessage: Bool {
        switch kind {
        case .operatorMessage, .choiceCard:
            return true
        default:
            return false
        }
    }

    let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

    init(with message: OutgoingMessage) {
        kind = .outgoingMessage(message)
    }

    init?(with message: ChatMessage, fromHistory: Bool = false) {
        switch message.sender {
        case .visitor:
            kind = .visitorMessage(message, status: nil)
        case .operator:
            kind = message.isChoiceCard
                ? .choiceCard(message, showsImage: false, imageUrl: nil, isActive: !fromHistory)
                : .operatorMessage(message, showsImage: false, imageUrl: nil)
        case .omniguide, .system, .unknown:
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
        case callUpgrade(ObservableValue<CallKind>, duration: ObservableValue<Int>)
        case operatorConnected(name: String?, imageUrl: String?)
    }
}
