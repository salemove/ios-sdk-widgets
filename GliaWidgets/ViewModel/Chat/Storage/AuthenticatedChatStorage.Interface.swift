struct AuthenticatedChatStorage {
    typealias QueueId = String
    typealias MessageId = String

    var isEmpty: () -> Bool

    var messages: (
        _ queueId: QueueId
    ) -> [ChatMessage]

    var updateMessage: (
        _ message: ChatMessage
    ) -> Void

    var storeMessage: (
        _ message: CoreSdkClient.Message,
        _ queueId: QueueId,
        _ operator: CoreSdkClient.Operator?
    ) -> Void

    var storeMessages: (
        _ messages: [CoreSdkClient.Message],
        _ queueId: QueueId,
        _ operator: CoreSdkClient.Operator?
    ) -> Void

    var isNewMessage: (
        _ message: CoreSdkClient.Message
    ) -> Bool

    var newMessages: (
        _ messages: [CoreSdkClient.Message]
    ) -> [CoreSdkClient.Message]

    var clear: () -> Void
}

extension AuthenticatedChatStorage {
    final class StorageRef {
        typealias QueueId = AuthenticatedChatStorage.QueueId
        typealias MessageId = AuthenticatedChatStorage.MessageId

        var messages: [ChatMessage] = []
    }
}
