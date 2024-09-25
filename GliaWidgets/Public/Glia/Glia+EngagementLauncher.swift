import Foundation

extension Glia {
    /// Retrieves an instance of `EngagementLauncher`.
    ///
    /// - Parameters:
    ///   - queueIds: A list of queue IDs to be used for the engagement launcher. When nil, the default queues will be used.
    ///
    /// - Returns:
    ///   - `EngagementLauncher` instance.
    public func getEngagementLauncher(queueIds: [String]?) -> EngagementLauncher {
        .init(queueIds: queueIds)
    }
}
