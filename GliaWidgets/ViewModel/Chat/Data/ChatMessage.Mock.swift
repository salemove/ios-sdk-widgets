#if DEBUG
extension ChatMessage {
    static func mock(
        id: String = "",
        queueID: String? = nil,
        `operator`: ChatOperator? = nil,
        sender: ChatMessageSender = .visitor,
        content: String = "",
        attachment: ChatAttachment? = nil,
        downloads: [FileDownload] = []
    ) -> ChatMessage {
        .init(
            id: id,
            queueID: queueID,
            operator: `operator`,
            sender: sender,
            content: content,
            attachment: attachment,
            downloads: downloads
        )
    }
}
#endif
