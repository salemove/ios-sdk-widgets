import SalemoveSDK

class ChatItem {
    enum Kind {
        case queueOperator
        case outgoingMessage(OutgoingMessage)
        case visitorMessage(ChatMessage, status: String?)
        case operatorMessage(ChatMessage, showsImage: Bool, imageUrl: String?)
        case callUpgrade(ValueProvider<CallKind>, durationProvider: ValueProvider<Int>)
    }

    var isOperatorMessage: Bool {
        switch kind {
        case .operatorMessage:
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

    init?(with message: ChatMessage) {
        switch message.sender {
        case .visitor:
            kind = .visitorMessage(message, status: nil)
        case .operator:
            kind = .operatorMessage(message, showsImage: false, imageUrl: nil)
        case .omniguide:
            return nil
        case .system:
            return nil
        }
    }
}
