import Foundation

class OutgoingMessage: Equatable {
    let id: String
    let content: String
    let files: [LocalFile]

    init(
        id: String = UUID().uuidString,
        content: String,
        files: [LocalFile] = []
    ) {
        self.id = id
        self.content = content
        self.files = files
    }

    static func == (lhs: OutgoingMessage, rhs: OutgoingMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.files == rhs.files
    }
}
