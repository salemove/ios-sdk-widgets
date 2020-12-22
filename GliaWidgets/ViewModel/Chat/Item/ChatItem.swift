import SalemoveSDK

struct ChatItem {
    enum Kind {
        case queueOperator
        case outgoingMessage(OutgoingMessage)
        case visitorMessage(Message, status: String?)
        case operatorMessage(Message, showsImage: Bool, imageUrl: String?)
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

    init?(with message: Message) {
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
