import Foundation

public struct Queue: Equatable {
    /// Queue identifier
    public let id: String
    /// Queue name
    public let name: String
    /// Queue state
    public let status: QueueStatus
    /// An array of media types for which queuing is enabled
    public let media: [MediaType]
    /// Indicates that queue is the default. `true` if Queue is default
    public let isDefault: Bool
    /// Queue dispatch time
    public let lastUpdated: Date

    /// Initializes Queue.
    ///
    /// - Parameters:
    ///   - id: Queue identifier.
    ///   - name: Queue name.
    ///   - status: Queue status.
    ///   - isDefault: Indicates that queue is the default.
    ///   - media: An array of media types for which queuing is enabled.
    ///   - lastUpdated: Queue dispatch time
    public init(
        id: String,
        name: String,
        status: QueueStatus,
        media: [MediaType],
        isDefault: Bool,
        lastUpdated: Date
    ) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
        self.status = status
        self.media = media
        self.lastUpdated = lastUpdated
    }
}

extension CoreSdkClient.CoreQueue {
    func asWidgetSDKQueue() -> Queue {
        .init(
            id: self.id,
            name: self.name,
            status: .init(coreStatus: self.state.status),
            media: self.state.media.map({ .init(mediaType: $0) }),
            isDefault: isDefault,
            lastUpdated: lastUpdated
        )
    }
}

#if DEBUG
extension Queue {
    static func mock(
        id: String = "",
        name: String = "",
        status: QueueStatus = .unknown(""),
        isDefault: Bool = false,
        media: [MediaType] = [],
        lastUpdated: Date = Date()
    ) -> Queue {
        Queue(
            id: id,
            name: name,
            status: status,
            media: media,
            isDefault: isDefault,
            lastUpdated: lastUpdated
        )
    }
}
#endif
