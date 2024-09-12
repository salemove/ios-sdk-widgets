import Foundation

extension Glia {
    func restoreOngoingEngagement(
        configuration: Configuration,
        currentEngagement: CoreSdkClient.Engagement,
        interactor: Interactor,
        features: Features,
        maximize: Bool
    ) {
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

        startRootCoordinator(
            with: interactor,
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

        func showSnackBarMessage() {
            environment.snackBar.showSnackBarMessage(
                text: viewFactory.theme.snackBar.text,
                style: viewFactory.theme.snackBar,
                topMostViewController: GliaPresenter(
                    environment: .create(
                        with: self.environment,
                        log: self.loggerPhase.logger,
                        sceneProvider: nil
                    )
                ).topMostViewController,
                timerProviding: environment.timerProviding,
                gcd: environment.gcd,
                notificationCenter: environment.notificationCenter
            )
        }

        func showSnackBarIfNeeded() {
            environment.coreSdk.fetchSiteConfigurations { result in
                guard case let .success(site) = result else { return }
                guard site.mobileObservationEnabled == true else { return }
                guard site.mobileObservationIndicationEnabled == true else { return }
                showSnackBarMessage()
            }
        }

        showSnackBarIfNeeded()
    }
}
