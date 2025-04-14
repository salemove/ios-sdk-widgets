import Foundation

class OutgoingMessage: Equatable {
    let files: [LocalFile]
    /// Defines if the message is associated with Single Choice Response card
    /// or Custom Response card. Used for reloading an associated card.
    let relation: Relation
    var payload: CoreSdkClient.SendMessagePayload

    init(
        payload: CoreSdkClient.SendMessagePayload,
        files: [LocalFile] = [],
        relation: Relation = .none
    ) {
        self.payload = payload
        self.files = files
        self.relation = relation
    }

    static func == (lhs: OutgoingMessage, rhs: OutgoingMessage) -> Bool {
        lhs.payload == rhs.payload &&
        lhs.files == rhs.files &&
        lhs.relation == rhs.relation
    }
}

extension OutgoingMessage {
    enum Relation: Equatable {
        case none
        case singleChoice(messageId: CoreSdkClient.Message.Id)
        case customCard(messageId: MessageRenderer.Message.Identifier)
    }
}
