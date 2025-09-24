import Foundation

extension Glia {
    /// Used to restore a bubble for Secure Conversation engagement:
    /// - started by accepting engagement request;
    /// - started by Outbound message;
    /// - restored from Follow Up.
    func restoreOngoingEngagementIfPresent() async {
        guard let interactor, let configuration else { return }

        guard
            let currentEngagement = self.environment.coreSdk.getNonTransferredSecureConversationEngagement(),
            currentEngagement.source == .coreEngagement
        else { return }

        // Restore only if rootCoordinator is `nil`, meaning Glia screen is not set up.
        guard rootCoordinator == nil else { return }

        await restoreOngoingEngagement(
            configuration: configuration,
            currentEngagement: currentEngagement,
            interactor: interactor,
            features: features ?? [],
            maximize: false
        )
        loggerPhase.logger.prefixed(Self.self).info("Engagement was restored")
    }

    @MainActor
    func restoreOngoingEngagement(
        configuration: Configuration,
        currentEngagement: CoreSdkClient.Engagement,
        interactor: Interactor,
        features: Features,
        maximize: Bool
    ) async {
        engagementRestorationState = .restoring
        // In this case, where engagement is restored, LO acknowledgement dialog
        // should not appear again, however snack bar message has to be shown via
        // `showSnackBarIfNeeded` function.
        interactor.skipLiveObservationConfirmations = true

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

        var engagementKind = EngagementKind(media: ongoingEngagementMediaStreams)
        if pendingInteraction?.hasPendingInteraction == true {
            engagementKind = .messaging(.chatTranscript)
        }

        startRootCoordinator(
            with: interactor,
            viewFactory: viewFactory,
            sceneProvider: nil,
            engagementKind: engagementKind,
            features: features,
            maximize: maximize
        )

        // Show bubble view.
        if !maximize {
            self.rootCoordinator?.minimize()
        }

        do {
            let site = try await environment.coreSdk.fetchSiteConfigurations()
            guard site.mobileObservationEnabled == true else { return }
            guard site.mobileObservationIndicationEnabled == true else { return }
            showSnackBar(viewFactory: viewFactory)
        } catch {
            loggerPhase.logger.prefixed(Self.self).warning("Fetching site configuration failed")
        }

        engagementRestorationState = .restored
    }

    @MainActor
    func showSnackBar(viewFactory: ViewFactory) {
        showSnackBar(
            with: viewFactory.theme.snackBar.text,
            style: viewFactory.theme.snackBar
        )
    }
}
