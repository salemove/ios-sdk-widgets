import Foundation
import GliaCoreSDK

class OutgoingMessage: Equatable {
    let id: String
    let content: String
    let files: [LocalFile]
    let attachment: Attachment?

    init(
        id: String = UUID().uuidString,
        content: String,
        files: [LocalFile] = [],
        attachment: Attachment? = nil
    ) {
        self.id = id
        self.content = content
        self.files = files
        self.attachment = attachment
    }

    static func == (lhs: OutgoingMessage, rhs: OutgoingMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.files == rhs.files &&
        lhs.attachment == rhs.attachment
    }
}
