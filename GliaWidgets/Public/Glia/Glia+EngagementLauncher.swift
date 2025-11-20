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
        environment.openTelemetry.logger.logMethodUse(
            sdkType: .widgetsSdk,
            className: Self.self,
            methodName: "getEngagementLauncher",
            methodParams: ["queueIds"]
        )
        @discardableResult
        func getConfiguration() throws -> Configuration {
            guard let configuration else {
                throw GliaError.sdkIsNotConfigured
            }
            return configuration
        }

        @discardableResult
        func getInteractor() throws -> Interactor {
            guard let interactor else {
                loggerPhase.logger.prefixed(Self.self).warning("Interactor is missing")
                throw GliaError.sdkIsNotConfigured
            }
            // Interactor is initialized during configuration, which means that queueIds need
            // to be set in interactor when EngagementLauncher is requested.
            interactor.setQueuesIds(queueIds)
            return interactor
        }

        // In order to align behaviour between platforms,
        // `GliaError.engagementExists` is no longer thrown,
        // instead engagement is getting restored.
        try getConfiguration()
        try getInteractor()

        loggerPhase.logger.info("Returning an Engagement Launcher")

        return EngagementLauncher { [weak self] engagementKind, sceneProvider in
            guard let self else { return }
            Glia.sharedInstance.stopScrappingContextWithOCR()
            let parameters = try getEngagementParameters(
                configuration: getConfiguration(),
                interactor: getInteractor()
            )
            try self.resolveEngagementState(
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
