class OutgoingMessage {
    let id = UUID().uuidString
    let content: String
    let attachment: ChatAttachment?

    init(content: String, attachment: ChatAttachment?) {
        self.content = content
        self.attachment = attachment
    }
}
