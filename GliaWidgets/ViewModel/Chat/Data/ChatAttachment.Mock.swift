#if DEBUG
extension ChatAttachment {
    static func mock(
        type: ChatAttachmentType?,
        files: [ChatEngagementFile]?,
        imageUrl: String?,
        options: [ChatChoiceCardOption]?,
        selectedOption: String? = nil
    ) -> ChatAttachment {
        .init(
            type: type,
            files: files,
            imageUrl: imageUrl,
            options: options,
            selectedOption: selectedOption
        )
    }
}
#endif
