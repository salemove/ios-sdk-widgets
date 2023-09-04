import Foundation
import GliaCoreSDK

class OutgoingMessage: Equatable {
    let files: [LocalFile]
    var payload: CoreSdkClient.SendMessagePayload

    init(
        payload: CoreSdkClient.SendMessagePayload,
        files: [LocalFile] = []
    ) {
        self.payload = payload
        self.files = files
    }

    static func == (lhs: OutgoingMessage, rhs: OutgoingMessage) -> Bool {
        lhs.payload == rhs.payload &&
        lhs.files == rhs.files
    }
}
