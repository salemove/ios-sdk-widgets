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
        try getEntryWidget(queueIds: queueIds, configuration: .default)
    }

    func getEntryWidget(queueIds: [String], configuration: EntryWidget.Configuration) throws -> EntryWidget {
        EntryWidget(
            queueIds: queueIds,
            configuration: configuration,
            environment: .init(
                observeSecureUnreadMessageCount: environment.coreSdk.subscribeForUnreadSCMessageCount,
                unsubscribeFromUpdates: environment.coreSdk.unsubscribeFromUpdates,
                queuesMonitor: queuesMonitor,
                engagementLauncher: try getEngagementLauncher(queueIds: queueIds),
                theme: theme,
                log: loggerPhase.logger,
                isAuthenticated: environment.isAuthenticated,
                hasPendingInteraction: { [weak self] in
                    self?.hasPendingInteraction ?? false
                }
            )
        )
    }
}
