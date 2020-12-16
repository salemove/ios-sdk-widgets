import SalemoveSDK

struct ChatItem {
    enum Kind {
        case queueOperator
        case visitorMessage(Message)
        case operatorMessage(Message)
    }

    let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

    init?(with message: Message) {
        switch message.sender {
        case .visitor:
            kind = .visitorMessage(message)
        case .operator:
            kind = .operatorMessage(message)
        case .omniguide:
            return nil
        case .system:
            return nil
        }
    }
}
