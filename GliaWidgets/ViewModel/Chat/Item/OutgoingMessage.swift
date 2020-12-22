class OutgoingMessage {
    let id = UUID().uuidString
    let content: String

    init(content: String) {
        self.content = content
    }
}
