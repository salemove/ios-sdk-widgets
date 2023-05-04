import Foundation

#if DEBUG
extension OutgoingMessage {
    static func mock(
        id: String = UUID.mock.uuidString,
        content: String = "",
        files: [LocalFile] = []
    ) -> OutgoingMessage {
        .init(
            id: id,
            content: content,
            files: files
        )
    }
}
#endif
