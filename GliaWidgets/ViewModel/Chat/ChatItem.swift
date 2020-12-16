import SalemoveSDK

struct ChatItem {
    enum Kind {
        case queueOperator
        case sentMessage(Message)
        case receivedMessage(Message, Operator?)
    }

    let kind: Kind
}
