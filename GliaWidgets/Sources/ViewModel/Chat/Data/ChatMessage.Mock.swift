#if DEBUG
extension ChatMessage {
    static func mock(
        id: String = "",
        `operator`: ChatOperator? = nil,
        sender: ChatMessageSender = .visitor,
        content: String = "",
        attachment: ChatAttachment? = nil,
        downloads: [FileDownload] = [],
        metadata: MessageMetadata? = nil
    ) -> ChatMessage {
        .init(
            id: id,
            operator: `operator`,
            sender: sender,
            content: content,
            attachment: attachment,
            downloads: downloads,
            metadata: metadata
        )
    }
}
#endif
