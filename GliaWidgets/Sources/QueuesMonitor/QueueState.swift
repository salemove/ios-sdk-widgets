import Foundation
import GliaCoreSDK

public struct QueueState: Decodable, Equatable {
    /// Queue status
    public let status: QueueStatus
    /// An array of media types for which queuing is enabled
    public let media: [MediaType]

    /// Initializes QueueState.
    ///
    /// - Parameters:
    ///   - status: Queue status.
    ///   - media: An array of media types for which queuing is enabled.
    ///
    public init(
        status: QueueStatus,
        media: [MediaType]
    ) {
        self.status = status
        self.media = media
    }
}

extension GliaCoreSDK.QueueState {
    func asWidgetSDKQueueState() -> QueueState {
        .init(
            status: .init(coreStatus: status),
            media: media.map { MediaType(mediaType: $0) }
        )
    }
}
