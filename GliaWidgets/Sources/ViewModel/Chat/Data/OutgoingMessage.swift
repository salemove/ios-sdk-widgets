import Foundation

class OutgoingMessage: Equatable {
    let id = UUID().uuidString
    let content: String
    let files: [LocalFile]

    init(
        content: String,
        files: [LocalFile] = []
    ) {
        self.content = content
        self.files = files
    }

    static func == (lhs: OutgoingMessage, rhs: OutgoingMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.files == rhs.files
    }
}
