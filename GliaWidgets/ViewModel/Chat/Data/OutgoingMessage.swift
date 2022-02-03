import Foundation

class OutgoingMessage {
    let id = UUID().uuidString
    let content: String
    let files: [LocalFile]

    init(content: String, files: [LocalFile]) {
        self.content = content
        self.files = files
    }
}
