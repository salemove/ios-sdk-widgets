import Foundation

#if DEBUG
extension OutgoingMessage {
    static func mock(
        payload: CoreSdkClient.SendMessagePayload = .mock(),
        files: [LocalFile] = []
    ) -> OutgoingMessage {
        OutgoingMessage(
            payload: payload,
            files: files
        )
    }
}
#endif
