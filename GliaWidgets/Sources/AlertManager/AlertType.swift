import Foundation

enum AlertType {
    case message(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() -> Void)?
    )
    case criticalError(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() -> Void)?
    )
    case confirmation(
        conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: () -> Void
    )
    case leaveConversation(
        conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: () -> Void
    )
    case singleAction(
        conf: SingleActionAlertConfiguration,
        accessibilityIdentifier: String,
        actionTapped: () -> Void
    )
    case singleMediaUpgrade(
        SingleMediaUpgradeAlertConfiguration,
        accepted: () -> Void,
        declined: () -> Void
    )
    case screenShareOffer(
        ScreenShareOfferAlertConfiguration,
        accepted: () -> Void,
        declined: () -> Void
    )
    case liveObservationConfirmation(
        ConfirmationAlertConfiguration,
        link: (WebViewController.Link) -> Void,
        accepted: () -> Void,
        declined: () -> Void
    )
    case systemAlert(
        conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)?
    )
    case view(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() -> Void)?
    )

    /// Indicating presentation priority of an alert.
    /// Based on comparing values we can decide whether an alert can be replaced with another alert.
    var presentationPriority: PresentationPriority {
        switch self {
        case .singleAction, .singleMediaUpgrade, .screenShareOffer, .criticalError:
            return .highest
        case .confirmation, .liveObservationConfirmation:
            return .high
        case .message, .systemAlert, .view, .leaveConversation:
            return .regular
        }
    }
}
