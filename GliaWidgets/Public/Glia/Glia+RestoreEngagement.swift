import Foundation

extension Glia {
    func restoreOngoingEngagement(
        configuration: Configuration,
        currentEngagement: CoreSdkClient.Engagement,
        features: Features,
        maximize: Bool
    ) {
        // Creates interactor instance
        let createdInteractor = setupInteractor(
            configuration: configuration,
            queueIds: []
        )

        // In case engagement should be restarted, LO ack should not
        // be appeared again.
        createdInteractor.skipLiveObservationConfirmations = true // TODO: snack bar has to be shown, but not dialog

        // Apply company name to theme and get the modified theme.
        let modifiedTheme = applyCompanyName(using: configuration, theme: theme)

        let viewFactory = ViewFactory(
            with: modifiedTheme,
            messageRenderer: messageRenderer,
            environment: .create(
                with: self.environment,
                loggerPhase: self.loggerPhase
            )
        )

        // If ongoing engagement exists on Core SDK side the engagement kind should be corrected
        // to correct one before restoring it.
        // Currently, CoreSDK can't restore video stream.
        let ongoingEngagementMediaStreams = CoreSdkClient.Engagement.Media(
            audio: currentEngagement.mediaStreams.audio,
            video: nil
        )

        startRootCoordinator(
            with: createdInteractor,
            viewFactory: viewFactory,
            sceneProvider: nil,
            engagementKind: EngagementKind(media: ongoingEngagementMediaStreams),
            features: features,
            maximize: maximize
        )

        // Show bubble view.
        if !maximize {
            self.rootCoordinator?.minimize()
        }
    }
}
