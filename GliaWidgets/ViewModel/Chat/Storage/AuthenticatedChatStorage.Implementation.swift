extension AuthenticatedChatStorage {
    static func inMemory(_ storage: StorageRef) -> Self {
        Self(
            isEmpty: {
                storage.messages.isEmpty
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
                messages
            },
            clear: {
                storage.clear()
            }
        )
    }
}

extension AuthenticatedChatStorage.StorageRef {
    func storeMessage(
        _ newMessage: ChatMessage,
        for queueId: AuthenticatedChatStorage.QueueId
    ) {
        messages.append(newMessage)
    }

    func messagesForQueue(_ queueID: QueueId) -> [ChatMessage] {
        messages
    }

    func updateMessage(_ message: ChatMessage) {
        guard
            let index = messages.firstIndex(where: { $0.id == message.id }),
            messages.count > index
        else {
            return
        }
        messages[index] = message
    }

    func isNewMessage(_ messageId: MessageId) -> Bool {
        !messages.contains(where: { $0.id == messageId })
    }

    func clear() {
        messages.removeAll()
    }
}
