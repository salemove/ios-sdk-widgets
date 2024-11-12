import Foundation

extension Glia {
    /// Retrieves an instance of `EngagementLauncher`.
    ///
    /// - Parameters:
    ///   - queueIds: A list of queue IDs to be used for the engagement launcher. When nil, the default queues will be used.
    ///
    /// - Returns:
    ///   - `EngagementLauncher` instance.
    public func getEngagementLauncher(queueIds: [String]) throws -> EngagementLauncher {
        let parameters = try getEngagementParameters(in: queueIds)
        loggerPhase.logger.info("Returning an Engagement Launcher")
        return try EngagementLauncher { [weak self] engagementKind, sceneProvider in
            try self?.resolveEngangementState(
                engagementKind: engagementKind,
                sceneProvider: sceneProvider,
                configuration: parameters.configuration,
                interactor: parameters.interactor,
                features: parameters.features,
                viewFactory: parameters.viewFactory,
                ongoingEngagementMediaStreams: parameters.ongoingEngagementMediaStreams
            )
        }
    }
}
