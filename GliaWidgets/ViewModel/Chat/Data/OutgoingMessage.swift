class OutgoingMessage {
    let id = UUID().uuidString
    let content: String
    let attachment: ChatAttachment?
    var files = [LocalFile]()

    init(content: String, attachment: ChatAttachment?) {
        self.content = content
        self.attachment = attachment
    }
}
