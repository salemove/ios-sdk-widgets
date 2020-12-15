import SalemoveSDK

struct ChatItem {
    enum Kind {
        case sentMessage(Message)
        case receivedMessage(Message, Operator?)
    }

    let kind: Kind
    var showsSenderImage = false
}

extension ChatItem {
    var message: String {
        switch kind {
        case .sentMessage(let message):
            return message.content
        case .receivedMessage(let message, _):
            return message.content
        }
    }

    var senderImageUrl: String? {
        switch kind {
        case .sentMessage:
            return nil
        case .receivedMessage(_, let engagementOperator):
            return engagementOperator?.picture?.url
        }
    }
}
