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

extension ChatItem.Kind: Equatable {
    static func == (lhs: ChatItem.Kind, rhs: ChatItem.Kind) -> Bool {
        switch (lhs, rhs) {
        case (.queueOperator, .queueOperator):
            return true

        case (.outgoingMessage(let lhsMessage), .outgoingMessage(let rhsMessage)):
            return lhsMessage.id == rhsMessage.id

        case (.visitorMessage(let lhsMessage, _), .visitorMessage(let rhsMessage, _)):
            return lhsMessage.id == rhsMessage.id

        case (.operatorMessage(let lhsMessage, _, _), .operatorMessage(let rhsMessage, _, _)):
            return lhsMessage.id == rhsMessage.id

        case (.choiceCard(let lhsMessage, _, _, _), .choiceCard(let rhsMessage, _, _, _)):
            return lhsMessage.id == rhsMessage.id

        case (.callUpgrade(let lhsKind, let lhsDuration), .callUpgrade(let rhsKind, let rhsDuration)):
            return lhsKind.value == rhsKind.value
                && lhsDuration.value == rhsDuration.value

        case (.operatorConnected(let lhsName, let lhsImageUrl), .operatorConnected(let rhsName, let rhsImageUrl)):
            return lhsName == rhsName
                && lhsImageUrl == rhsImageUrl
        default:
            return false
        }
    }
}
