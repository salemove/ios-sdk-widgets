struct ChatItem {
    enum Kind {
        case sentMessage
    }

    let kind: Kind
}
