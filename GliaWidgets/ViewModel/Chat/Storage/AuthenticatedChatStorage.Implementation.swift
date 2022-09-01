extension AuthenticatedChatStorage {
    static func inMemory(_ storage: StorageRef) -> Self {
        Self(
            isEmpty: {
                storage.messageIdsForQueue.isEmpty
            },
            messages: { queueId in
                storage.messagesForQueue(queueId)
            },
            updateMessage: { message in
                storage.updateMessage(message)
            },
            storeMessage: { message, queueId, engagedOperator in
                storage.storeMessage(
                    .init(with: message,
                          queueID: queueId,
                          operator: engagedOperator
                         ),
                    for: queueId
                )
            },
            storeMessages: { messages, queueId, engagedOperator in
                for message in messages {
                    storage.storeMessage(
                        .init(
                            with: message,
                            queueID: queueId,
                            operator: engagedOperator
                        ),
                        for: queueId
                    )
                }
            },
            isNewMessage: { message in
                storage.isNewMessage(message.id)
            },
            newMessages: { messages in
                // This logic is copied from `ChatStorage.newMessages`,
                // however it doesn't seem to be reasonable.
                // Let's discuss it during the code review.
                let existingMessageIDs = messages.map(\.id)
                return messages.filter { !existingMessageIDs.contains($0.id) }
            },
            clear: {
                storage.clear()
            }
        )
    }
}

extension AuthenticatedChatStorage.StorageRef {
    func storeMessage(
        _ message: ChatMessage,
        for queueId: AuthenticatedChatStorage.QueueId
    ) {
        var messageIds = messageIdsForQueue[queueId, default: []]
        messageIds.append(message.id)
        messageForMessageId[message.id] = message
        messageIdsForQueue[queueId] = messageIds
    }

    func messagesForQueue(_ queueID: QueueId) -> [ChatMessage] {
        messageIdsForQueue[queueID].map { messageIds in
            messageIds
                .compactMap { messageId in
                    self.messageForMessageId[messageId]
                }
        } ?? []
    }

    func updateMessage(_ message: ChatMessage) {
        messageForMessageId[message.id] = message
    }

    func isNewMessage(_ messageId: MessageId) -> Bool {
        messageForMessageId[messageId] == nil
    }

    func clear() {
        messageIdsForQueue.removeAll()
        messageForMessageId.removeAll()
    }
}
