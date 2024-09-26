import Foundation

extension Glia {
    /// Retrieves an instance of `EntryWidget`.
    ///
    /// - Parameters:
    ///   - queueIds: A list of queue IDs to be used for the engagement launcher. When nil, the default queues will be used.
    ///
    /// - Returns:
    ///   - `EntryWidget` instance.
    public func getEntryWidget(queueIds: [String]) -> EntryWidget {
        // The real implementation will be added once EngagementLauncher is added
        .init(theme: theme)
    }
}
