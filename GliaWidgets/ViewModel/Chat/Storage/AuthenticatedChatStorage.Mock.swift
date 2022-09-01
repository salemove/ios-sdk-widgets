extension AuthenticatedChatStorage {
    static let mock = Self(
        isEmpty: { false },
        messages: { _ in [] },
        updateMessage: { _ in },
        storeMessage: { _, _, _ in },
        storeMessages: { _, _, _ in },
        isNewMessage: { _ in false },
        newMessages: { _ in [] },
        clear: {}
    )
}
