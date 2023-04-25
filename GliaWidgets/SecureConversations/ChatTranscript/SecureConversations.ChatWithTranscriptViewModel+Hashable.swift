import Foundation

extension SecureConversations.TranscriptModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: SecureConversations.TranscriptModel, rhs: SecureConversations.TranscriptModel) -> Bool {
        lhs === rhs
    }
}
