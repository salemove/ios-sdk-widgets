#if DEBUG
extension ChatMessage {
    static func mock(
        id: String,
        queueID: String?,
        `operator`: ChatOperator?,
        sender: ChatMessageSender,
        content: String,
        attachment: ChatAttachment?,
        downloads: [FileDownload]
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
