enum ChatStorageState {
    case unauthenticated(Glia.Environment.ChatStorage)
    case authenticated(AuthenticatedChatStorage)
}


extension ChatStorageState {
    func isEmpty() -> Bool {
        switch self {
        case let .unauthenticated(unauthenticatedStorage):
            return unauthenticatedStorage.isEmpty()
        case let .authenticated(authenticatedStorage):
            return authenticatedStorage.isEmpty()
        }
    }

    func messages(_ queueId: String) -> [ChatMessage] {
        switch self {
        case let .unauthenticated(unauthenticatedStorage):
            return unauthenticatedStorage.messages(queueId)
        case let .authenticated(authenticatedStorage):
            return authenticatedStorage.messages(queueId)
        }
    }

    func isNewMessage(_ message: CoreSdkClient.Message) -> Bool {
        switch self {
        case let .unauthenticated(unauthenticatedStorage):
            return unauthenticatedStorage.isNewMessage(message)
        case let .authenticated(authenticatedStorage):
            return authenticatedStorage.isNewMessage(message)
        }
    }

    func storeMessage(
        _ message: CoreSdkClient.Message,
        _ queueId: String,
        _ engagedOperator: CoreSdkClient.Operator?
    ) {
        switch self {
        case let .unauthenticated(unauthenticatedStorage):
            unauthenticatedStorage.storeMessage(
                message,
                queueId,
                engagedOperator
            )
        case let .authenticated(authenticatedStorage):
            return authenticatedStorage.storeMessage(
                message,
                queueId,
                engagedOperator
            )
        }
    }

    func newMessages(_ messages: [CoreSdkClient.Message]) -> [CoreSdkClient.Message] {
        switch self {
        case let .unauthenticated(unauthenticatedStorage):
            return unauthenticatedStorage.newMessages(messages)
        case let .authenticated(authenticatedStorage):
            return authenticatedStorage.newMessages(messages)
        }
    }

    func storeMessages(
        _ newMessages: [CoreSdkClient.Message],
        _ queueId: String,
        _ engagedOperator: CoreSdkClient.Operator?
    ) {
        switch self {
        case let .unauthenticated(unauthenticatedStorage):
            unauthenticatedStorage.storeMessages(
                newMessages,
                queueId,
                engagedOperator
            )
        case let .authenticated(authenticatedStorage):
            authenticatedStorage.storeMessages(
                newMessages,
                queueId,
                engagedOperator
            )
        }
    }

    func updateMessage(_ chatMessage: ChatMessage) {
        switch self {
        case let .unauthenticated(unauthenticatedStorage):
            return unauthenticatedStorage.updateMessage(chatMessage)
        case let .authenticated(authenticatedStorage):
            return authenticatedStorage.updateMessage(chatMessage)
        }
    }
}
