class OutgoingMessage {
    let id = UUID().uuidString
    let content: String
    let attachment: ChatAttachment?
    var downloads: [FileDownload<ChatEngagementFile>]?

    init(content: String, attachment: ChatAttachment?) {
        self.content = content
        self.attachment = attachment
    }
}
