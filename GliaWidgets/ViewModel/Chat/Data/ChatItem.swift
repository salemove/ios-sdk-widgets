import SalemoveSDK

class ChatItem {
    enum Kind {
        case queueOperator
        case outgoingMessage(OutgoingMessage)
        case visitorMessage(ChatMessage, status: String?)
        case operatorMessage(ChatMessage, showsImage: Bool, imageUrl: String?)
        case choiceCard(ChatMessage, showsImage: Bool, imageUrl: String?, selectedOption: String? = nil)
        case callUpgrade(ObservableValue<CallKind>, duration: ObservableValue<Int>)
    }

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

    init?(with message: ChatMessage) {
        switch message.sender {
        case .visitor:
            kind = .visitorMessage(message, status: nil)
        case .operator:
            kind = message.isChoiceCard
                ? .choiceCard(message, showsImage: false, imageUrl: nil)
                : .operatorMessage(message, showsImage: false, imageUrl: nil)
        case .omniguide, .system, .unknown:
            return nil
        }
    }
}
