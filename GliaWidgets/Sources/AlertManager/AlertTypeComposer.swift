import UIKit

extension AlertManager {
    /// The `AlertTypeComposer` is responsible for composing different 
    /// types of alerts based on the input type and placement. It uses
    /// the provided environment and theme to configure and customize
    /// the alert views.
    struct AlertTypeComposer {
        /// The environment configuration for the alert type composer,
        /// including logging.
        private let environment: Environment

        /// The theme used to style the alert views.
        private var theme: Theme

        /// - Parameters:
        ///   - environment: The environment configuration for the alert type composer.
        ///   - theme: The theme used to style the alert views.
        ///
        init(
            environment: Environment,
            theme: Theme
        ) {
            self.environment = environment
            self.theme = theme
        }
    }
}

extension AlertManager.AlertTypeComposer {
    /// Composes an alert of the specified type and placement.
    /// - Parameters:
    ///   - type: The input type of the alert.
    ///   - placement: The placement of the alert.
    /// - Returns: The composed alert type.
    ///
    func composeAlert(
        input: AlertInputType
    ) throws -> AlertType {
        switch input {
        case let .mediaSourceNotAvailable(dismissed):
            return mediaTypeNotAvailableAlertType(dismissed: dismissed)
        case let .cameraSettings(dismissed):
            return noCameraPermissionAlertType(dismissed: dismissed)
        case let .microphoneSettings(dismissed):
            return noMicrophonePermissionAlertType(dismissed: dismissed)
        case let .unsupportedGvaBroadcastError(dismissed):
            return unsupportedGvaBroadcastErrorAlertType(dismissed: dismissed)
        case let .unavailableMessageCenter(dismissed):
            return unavailableMessageCenterAlertType(dismissed: dismissed)
        case let .unavailableMessageCenterForBeingUnauthenticated(dismissed):
            return unavailableMessageCenterForBeingUnauthenticatedAlertType(dismissed: dismissed)
        case let .liveObservationConfirmation(link, accepted, declined):
            return liveObservationConfirmationAlertType(
                link: link,
                accepted: accepted,
                declined: declined
            )
        case let .operatorEndedEngagement(action):
            return operatorEndedEngagementAlertType(action: action)
        case let .leaveQueue(confirmed):
            return leaveQueueAlertType(confirmed: confirmed)
        case let .endEngagement(confirmed):
            return endEngagementAlertType(confirmed: confirmed)
        case let .mediaUpgrade(operators, offer, accepted, declined, answer):
            return try mediaUpgradeOfferAlertType(
                operators: operators,
                offer: offer,
                accepted: accepted,
                declined: declined,
                answer: answer
            )
        case let .error(error, dismissed):
            return composeErrorAlert(
                error: error,
                dismissed: dismissed
            )
        case let .leaveCurrentConversation(confirmed, declined):
            return leaveCurrentConversationAlertType(confirmed: confirmed, declined: declined)
        case let .requestPushNotificationsPermissions(confirmed, declined):
            return requestPNPermissionsAlertType(accepted: confirmed, declined: declined)
        }
    }

    /// Overrides the current theme with a new theme.
    /// - Parameters:
    ///   - newTheme: The new theme to apply.
    ///
    mutating func overrideTheme(with newTheme: Theme) {
        self.theme = newTheme
    }
}

private extension AlertManager.AlertTypeComposer {
    /// Composes an error alert based on the provided error and placement.
    /// - Parameters:
    ///   - error: The error to be displayed in the alert.
    ///   - dismissed: A closure to be called when the alert is dismissed.
    ///   - location: The placement of the alert.
    /// - Returns: The composed alert type for the error.
    ///
    func composeErrorAlert(
        error: (any Error)?,
        dismissed: (() -> Void)? = nil
    ) -> AlertType {
        switch error {
        case let queueError as CoreSdkClient.QueueError:
            switch queueError {
            case .queueClosed:
                return queueClosedAlertType(dismissed: dismissed)
            case .queueFull:
                return queueFullAlertType(dismissed: dismissed)
            default:
                return unexpectedErrorAlertType(dismissed: dismissed)
            }
        case let authenticationError as CoreSdkClient.Authentication.Error:
            switch authenticationError {
            case .expiredAccessToken:
                return expiredAccessTokenAlertType(dismissed: dismissed)
            default:
                return unexpectedErrorAlertType(dismissed: dismissed)
            }
        default:
            return unexpectedErrorAlertType(dismissed: dismissed)
        }
    }

    func queueClosedAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        .message(
            conf: theme.alertConfiguration.operatorsUnavailable,
            accessibilityIdentifier: "alert_queue_closed",
            dismissed: dismissed
        )
    }

    func queueFullAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        environment.log.prefixed(Self.self).info("Show No More Operators Dialog")
        return .message(
            conf: theme.alertConfiguration.operatorsUnavailable,
            accessibilityIdentifier: "alert_queue_full",
            dismissed: dismissed
        )
    }

    func unexpectedErrorAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Unexpected error Dialog")
        return .message(
            conf: theme.alertConfiguration.unexpectedError,
            accessibilityIdentifier: nil,
            dismissed: dismissed
        )
    }

    func expiredAccessTokenAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        environment.log.prefixed(Self.self).info("Show authentication error Dialog")
        return .criticalError(
            conf: theme.alertConfiguration.expiredAccessTokenError,
            accessibilityIdentifier: "alert_expired_access_token",
            dismissed: dismissed
        )
    }

    func mediaTypeNotAvailableAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        .message(
            conf: theme.alertConfiguration.mediaSourceNotAvailable,
            accessibilityIdentifier: nil,
            dismissed: dismissed
        )
    }

    func noCameraPermissionAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        .systemAlert(
            conf: theme.alertConfiguration.cameraSettings,
            cancelled: dismissed
        )
    }

    func noMicrophonePermissionAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        .systemAlert(
            conf: theme.alertConfiguration.microphoneSettings,
            cancelled: dismissed
        )
    }

    func unsupportedGvaBroadcastErrorAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        .message(
            conf: theme.alertConfiguration.unsupportedGvaBroadcastError,
            accessibilityIdentifier: nil,
            dismissed: dismissed
        )
    }

    func unavailableMessageCenterAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Message Center Unavailable Dialog")
        return .view(
            conf: theme.alertConfiguration.unavailableMessageCenter,
            accessibilityIdentifier: "unavailable_message_center_alert_identifier",
            dismissed: dismissed
        )
    }

    func unavailableMessageCenterForBeingUnauthenticatedAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        self.environment.log.prefixed(Self.self).info("Show Unauthenticated Dialog")
        return .view(
            conf: theme.alertConfiguration.unavailableMessageCenterForBeingUnauthenticated,
            accessibilityIdentifier: "unavailable_message_center_alert_identifier",
            dismissed: dismissed
        )
    }

    func liveObservationConfirmationAlertType(
        link: @escaping (WebViewController.Link) -> Void,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) -> AlertType {
        .liveObservationConfirmation(
            theme.alertConfiguration.liveObservationConfirmation,
            link: link,
            accepted: accepted,
            declined: declined
        )
    }

    func operatorEndedEngagementAlertType(action: @escaping () -> Void) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Engagement Ended Dialog")
        return .singleAction(
            conf: theme.alertConfiguration.operatorEndedEngagement,
            accessibilityIdentifier: "alert_close_engagementEnded",
            actionTapped: action
        )
    }

    func leaveQueueAlertType(confirmed: @escaping () -> Void) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Exit Queue Dialog")
        return .confirmation(
            conf: theme.alertConfiguration.leaveQueue,
            accessibilityIdentifier: "alert_confirmation_leaveQueue",
            confirmed: confirmed
        )
    }

    func endEngagementAlertType(confirmed: @escaping () -> Void) -> AlertType {
        environment.log.prefixed(Self.self).info("Show End Engagement Dialog")
        return .confirmation(
            conf: theme.alertConfiguration.endEngagement,
            accessibilityIdentifier: "alert_confirmation_endEngagement",
            confirmed: confirmed
        )
    }

    func mediaUpgradeOfferAlertType(
        operators: String,
        offer: CoreSdkClient.MediaUpgradeOffer,
        accepted: (() -> Void)? = nil,
        declined: (() -> Void)? = nil,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) throws -> AlertType {
        let acceptedOffer: () -> Void = {
            self.environment.log.prefixed(Self.self).info("Upgrade offer accepted by visitor")
            accepted?()
            answer(true, nil)
        }

        let declinedOffer: () -> Void = {
            self.environment.log.prefixed(Self.self).info("Upgrade offer declined by visitor")
            declined?()
            answer(false, nil)
        }

        let configuration: SingleMediaUpgradeAlertConfiguration

        switch offer.type {
        case .audio:
            environment.log.prefixed(Self.self).info("Audio upgrade requested")
            environment.log.prefixed(Self.self).info("Show Upgrade Audio Dialog")
            configuration = theme.alertConfiguration.audioUpgrade.withOperatorName(operators)
        case .video where offer.direction == .oneWay:
            environment.log.prefixed(Self.self).info("1 way video upgrade requested")
            environment.log.prefixed(Self.self).info("Show Upgrade 1WayVideo Dialog")
            configuration = theme.alertConfiguration.oneWayVideoUpgrade.withOperatorName(operators)
        case .video where offer.direction == .twoWay:
            environment.log.prefixed(Self.self).info("2 way video upgrade requested")
            environment.log.prefixed(Self.self).info("Show Upgrade 2WayVideo Dialog")
            configuration = theme.alertConfiguration.twoWayVideoUpgrade.withOperatorName(operators)
        default:
            environment.log.prefixed(Self.self).warning("Unsupported media upgrade offer type requested")
            throw GliaError.internalError
        }

        return .singleMediaUpgrade(
            configuration,
            accepted: acceptedOffer,
            declined: declinedOffer
        )
    }

    func leaveCurrentConversationAlertType(confirmed: @escaping () -> Void, declined: (() -> Void)?) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Leave Current Conversations Dialog")
        return .leaveConversation(
            conf: theme.alertConfiguration.leaveCurrentConversation,
            accessibilityIdentifier: "alert_confirmation_leaveCurrentConversation",
            confirmed: confirmed,
            declined: declined
        )
    }

    func requestPNPermissionsAlertType(
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Push Notifications Intermediate Dialog")
        return .requestPushNotificationsPermissions(
            conf: theme.alertConfiguration.pushNotificationsPermissions,
            accepted: accepted,
            declined: declined
        )
    }
}
