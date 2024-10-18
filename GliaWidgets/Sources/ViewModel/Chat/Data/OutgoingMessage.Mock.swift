import Foundation

#if DEBUG
extension OutgoingMessage {
    static func mock(
        payload: CoreSdkClient.SendMessagePayload = .mock(),
        files: [LocalFile] = [],
        relation: Relation = .none
    ) -> OutgoingMessage {
        OutgoingMessage(
            payload: payload,
            files: files,
            relation: relation
        )
    }
}
#endif
