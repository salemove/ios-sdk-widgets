@testable import GliaWidgets

extension ChatItem.Kind: Equatable {
    public static func == (lhs: ChatItem.Kind, rhs: ChatItem.Kind) -> Bool {
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

        case (.transferring, .transferring):
            return true

        default:
            return false
        }
    }
}
