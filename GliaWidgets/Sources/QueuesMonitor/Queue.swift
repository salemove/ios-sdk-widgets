import Foundation
import GliaCoreSDK

public struct Queue: Equatable {
    /// Queue identifier
    public let id: String
    /// Queue name
    public let name: String
    /// Queue state
    public let state: QueueState
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
        state: QueueState,
        isDefault: Bool,
        lastUpdated: Date
    ) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
        self.state = state
        self.lastUpdated = lastUpdated
    }
}

extension GliaCoreSDK.Queue {
    func asWidgetSDKQueue() -> Queue {
        .init(
            id: self.id,
            name: self.name,
            state: state.asWidgetSDKQueueState(),
            isDefault: isDefault,
            lastUpdated: lastUpdated
        )
    }
}
