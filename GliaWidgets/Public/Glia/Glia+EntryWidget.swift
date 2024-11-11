import Foundation

extension Glia {
    /// Retrieves an instance of `EntryWidget`.
    ///
    /// - Parameters:
    ///   - queueIds: A list of queue IDs to be used for the engagement launcher. When nil, the default queues will be used.
    ///
    /// - Returns:
    ///   - `EntryWidget` instance.
    public func getEntryWidget(queueIds: [String]) throws -> EntryWidget {
        EntryWidget(
            queueIds: queueIds,
            environment: .init(
                observeSecureUnreadMessageCount: environment.coreSdk.subscribeForUnreadSCMessageCount,
                unsubscribeFromUpdates: environment.coreSdk.unsubscribeFromUpdates,
                queuesMonitor: environment.queuesMonitor,
                engagementLauncher: try getEngagementLauncher(queueIds: queueIds),
                theme: theme,
                log: loggerPhase.logger,
                isAuthenticated: environment.isAuthenticated
            )
        )
    }
}
