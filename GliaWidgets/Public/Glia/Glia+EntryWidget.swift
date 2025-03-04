import Foundation
import Combine

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
                hasPendingInteractionPublisher: { [weak self] in
                    guard let self, let pendingInteraction else {
                        return Just(false).eraseToAnyPublisher()
                    }
                    return pendingInteraction.$hasPendingInteraction.eraseToAnyPublisher()
                }(),
                interactorPublisher: $interactor.eraseToAnyPublisher(),
                onCallVisualizerResume: { [weak self] in
                    guard let self else { return }
                    callVisualizer.resume()
                },
                combineScheduler: environment.combineScheduler
            )
        )
    }
}
