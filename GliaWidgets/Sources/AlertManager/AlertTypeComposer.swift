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
        dismissed: (() async -> Void)? = nil
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

    func queueClosedAlertType(dismissed: (() async -> Void)? = nil) -> AlertType {
        logDialogShown(dialog: .queueIsClosed)
        return .message(
            conf: theme.alertConfiguration.operatorsUnavailable,
            accessibilityIdentifier: "alert_queue_closed",
            dismissed: {
                logButtonClicked(button: .close, dialog: .queueIsClosed)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .queueIsClosed)
            }
        )
    }

    func queueFullAlertType(dismissed: (() async -> Void)? = nil) -> AlertType {
        logDialogShown(dialog: .queueIsClosed)
        environment.log.prefixed(Self.self).info("Show No More Operators Dialog")
        return .message(
            conf: theme.alertConfiguration.operatorsUnavailable,
            accessibilityIdentifier: "alert_queue_full",
            dismissed: {
                logButtonClicked(button: .close, dialog: .queueIsClosed)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .queueIsClosed)
            }
        )
    }

    func unexpectedErrorAlertType(dismissed: (() async -> Void)? = nil) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Unexpected error Dialog")
        logDialogShown(dialog: .unexpectedError)
        return .message(
            conf: theme.alertConfiguration.unexpectedError,
            accessibilityIdentifier: nil,
            dismissed: {
                logButtonClicked(button: .close, dialog: .unexpectedError)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .unexpectedError)
            }
        )
    }

    func expiredAccessTokenAlertType(dismissed: (() async -> Void)? = nil) -> AlertType {
        environment.log.prefixed(Self.self).info("Show authentication error Dialog")
        logDialogShown(dialog: .unauthenticatedError)
        return .criticalError(
            conf: theme.alertConfiguration.expiredAccessTokenError,
            accessibilityIdentifier: "alert_expired_access_token",
            dismissed: {
                logButtonClicked(button: .close, dialog: .unauthenticatedError)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .unauthenticatedError)
            }
        )
    }

    func mediaTypeNotAvailableAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        logDialogShown(dialog: .unavailableMediaSource)
        return .message(
            conf: theme.alertConfiguration.mediaSourceNotAvailable,
            accessibilityIdentifier: nil,
            dismissed: {
                logButtonClicked(button: .close, dialog: .unavailableMediaSource)

                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .unavailableMediaSource)
            }
        )
    }

    func noCameraPermissionAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        logDialogShown(dialog: .missingPermission)
        return .systemAlert(
            conf: theme.alertConfiguration.cameraSettings,
            cancelled: {
                logButtonClicked(button: .close, dialog: .missingPermission)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .missingPermission)
            }
        )
    }

    func noMicrophonePermissionAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        logDialogShown(dialog: .missingPermission)
        return .systemAlert(
            conf: theme.alertConfiguration.microphoneSettings,
            cancelled: {
                logButtonClicked(button: .close, dialog: .missingPermission)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .missingPermission)
            }
        )
    }

    func unsupportedGvaBroadcastErrorAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        logDialogShown(dialog: .unsupportedGvaBroadcast)
        return .message(
            conf: theme.alertConfiguration.unsupportedGvaBroadcastError,
            accessibilityIdentifier: nil,
            dismissed: {
                logButtonClicked(button: .ok, dialog: .unsupportedGvaBroadcast)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .unsupportedGvaBroadcast)
            }
        )
    }

    func unavailableMessageCenterAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Message Center Unavailable Dialog")
        logDialogShown(dialog: .secureConversationUnavailableError)
        return .view(
            conf: theme.alertConfiguration.unavailableMessageCenter,
            accessibilityIdentifier: "unavailable_message_center_alert_identifier",
            dismissed: {
                logButtonClicked(button: .negative, dialog: .secureConversationUnavailableError)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .secureConversationUnavailableError)
            }
        )
    }

    func unavailableMessageCenterForBeingUnauthenticatedAlertType(dismissed: (() -> Void)? = nil) -> AlertType {
        self.environment.log.prefixed(Self.self).info("Show Unauthenticated Dialog")
        logDialogShown(dialog: .unauthenticatedError)
        return .view(
            conf: theme.alertConfiguration.unavailableMessageCenterForBeingUnauthenticated,
            accessibilityIdentifier: "unavailable_message_center_alert_identifier",
            dismissed: {
                logButtonClicked(button: .negative, dialog: .unauthenticatedError)
                dismissed?()
            }, onClose: {
                logDialogClosed(dialog: .unauthenticatedError)
            }
        )
    }

    func liveObservationConfirmationAlertType(
        link: @escaping (WebViewController.Link) -> Void,
        accepted: @escaping () async -> Void,
        declined: @escaping () async -> Void
    ) -> AlertType {
        logDialogShown(dialog: .liveObservationConfirmation)
        return .liveObservationConfirmation(
            theme.alertConfiguration.liveObservationConfirmation,
            link1: {
                logButtonClicked(button: .engagementConfirmationLink1, dialog: .liveObservationConfirmation)
                link($0)
            },
            link2: {
                logButtonClicked(button: .engagementConfirmationLink2, dialog: .liveObservationConfirmation)
                link($0)
            },
            accepted: {
                logButtonClicked(button: .positive, dialog: .liveObservationConfirmation)
                accepted()
            },
            declined: {
                logButtonClicked(button: .negative, dialog: .liveObservationConfirmation)
                declined()
            }, onClose: {
                logDialogClosed(dialog: .liveObservationConfirmation)
            }
        )
    }

    func operatorEndedEngagementAlertType(action: @escaping () async -> Void) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Engagement Ended Dialog")
        logDialogShown(dialog: .engagementEnded)
        return .singleAction(
            conf: theme.alertConfiguration.operatorEndedEngagement,
            accessibilityIdentifier: "alert_close_engagementEnded",
            actionTapped: {
                logButtonClicked(button: .ok, dialog: .engagementEnded)
                action()
            }, onClose: {
                logDialogClosed(dialog: .engagementEnded)
            }
        )
    }

    func leaveQueueAlertType(confirmed: @escaping () async -> Void) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Exit Queue Dialog")
        logDialogShown(dialog: .leaveQueueConfirmation)
        return .confirmation(
            conf: theme.alertConfiguration.leaveQueue,
            accessibilityIdentifier: "alert_confirmation_leaveQueue",
            confirmed: {
                logButtonClicked(button: .positive, dialog: .leaveQueueConfirmation)
                confirmed()
            },
            dismissed: {
                logButtonClicked(button: .negative, dialog: .leaveQueueConfirmation)
            }, onClose: {
                logDialogClosed(dialog: .leaveQueueConfirmation)
            }
        )
    }

    func endEngagementAlertType(confirmed: @escaping () async -> Void) -> AlertType {
        environment.log.prefixed(Self.self).info("Show End Engagement Dialog")
        logDialogShown(dialog: .leaveEngagementConfirmation)
        return .confirmation(
            conf: theme.alertConfiguration.endEngagement,
            accessibilityIdentifier: "alert_confirmation_endEngagement",
            confirmed: {
                logButtonClicked(button: .positive, dialog: .leaveEngagementConfirmation)
                confirmed()
            },
            dismissed: {
                logButtonClicked(button: .negative, dialog: .leaveEngagementConfirmation)
            }, onClose: {
                logDialogClosed(dialog: .leaveEngagementConfirmation)
            }
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
            logButtonClicked(button: .positive, dialog: .mediaUpgradeConfirmation, mediaOffer: offer)
            self.environment.log.prefixed(Self.self).info("Upgrade offer accepted by visitor")
            accepted?()
            answer(true, nil)
        }

        let declinedOffer: () -> Void = {
            logButtonClicked(button: .negative, dialog: .mediaUpgradeConfirmation, mediaOffer: offer)
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

        logDialogShown(dialog: .mediaUpgradeConfirmation, mediaOffer: offer)

        return .singleMediaUpgrade(
            configuration,
            accepted: acceptedOffer,
            declined: declinedOffer,
            onClose: {
                logDialogClosed(dialog: .mediaUpgradeConfirmation, mediaOffer: offer)
            }
        )
    }

    func leaveCurrentConversationAlertType(
        confirmed: @escaping () -> Void,
        declined: (() -> Void)?
    ) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Leave Current Conversations Dialog")
        logDialogShown(dialog: .leaveSecureConversationsConfirmation)
        return .leaveConversation(
            conf: theme.alertConfiguration.leaveCurrentConversation,
            accessibilityIdentifier: "alert_confirmation_leaveCurrentConversation",
            confirmed: {
                logButtonClicked(button: .positive, dialog: .leaveSecureConversationsConfirmation)
                confirmed()
            },
            declined: {
                logButtonClicked(button: .negative, dialog: .leaveSecureConversationsConfirmation)
                declined?()
            }, onClose: {
                logDialogClosed(dialog: .leaveSecureConversationsConfirmation)
            }
        )
    }

    func requestPNPermissionsAlertType(
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) -> AlertType {
        environment.log.prefixed(Self.self).info("Show Push Notifications Intermediate Dialog")
        logDialogShown(dialog: .allowPushNotification)
        return .requestPushNotificationsPermissions(
            conf: theme.alertConfiguration.pushNotificationsPermissions,
            accepted: {
                logButtonClicked(button: .positive, dialog: .allowPushNotification)
                accepted()
            },
            declined: {
                logButtonClicked(button: .negative, dialog: .allowPushNotification)
                declined()
            }, onClose: {
                logDialogClosed(dialog: .allowPushNotification)
            }
        )
    }
}

extension AlertManager.AlertTypeComposer {
    func logDialogShown(
        dialog: OtelDialogNames,
        mediaOffer: CoreSdkClient.MediaUpgradeOffer? = nil
    ) {
        logEvent(
            event: .dialogShown,
            dialog: dialog,
            mediaOffer: mediaOffer
        )
    }

    func logDialogClosed(
        dialog: OtelDialogNames,
        mediaOffer: CoreSdkClient.MediaUpgradeOffer? = nil
    ) {
        logEvent(
            event: .dialogClosed,
            dialog: dialog,
            mediaOffer: mediaOffer
        )
    }

    func logButtonClicked(
        button: OtelButtonNames,
        dialog: OtelDialogNames,
        mediaOffer: CoreSdkClient.MediaUpgradeOffer? = nil
    ) {
        logEvent(
            event: .dialogButtonClicked,
            dialog: dialog,
            button: button,
            mediaOffer: mediaOffer
        )
    }

    private func logEvent(
        event: OtelLogEvents,
        dialog: OtelDialogNames,
        button: OtelButtonNames? = nil,
        mediaOffer: CoreSdkClient.MediaUpgradeOffer? = nil
    ) {
        environment.openTelemetry.logger.i(event) {
            $0[.dialogName] = .string(dialog.rawValue)
            if let button {
                $0[.buttonName] = .string(button.rawValue)
            }
            if let offerAttribute = mediaOffer?.otelAttribute {
                $0[.engagementType] = offerAttribute
            }
        }
    }
}
