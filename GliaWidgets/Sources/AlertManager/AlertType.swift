import Foundation

enum AlertType {
    case message(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() async -> Void)?
    )
    case criticalError(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() async -> Void)?
    )
    case confirmation(
        conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: () async -> Void
    )
    case leaveConversation(
        conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: () -> Void,
        declined: (() -> Void)?
    )
    case singleAction(
        conf: SingleActionAlertConfiguration,
        accessibilityIdentifier: String,
        actionTapped: () async -> Void
    )
    case singleMediaUpgrade(
        SingleMediaUpgradeAlertConfiguration,
        accepted: () -> Void,
        declined: () -> Void
    )
    case liveObservationConfirmation(
        ConfirmationAlertConfiguration,
        link: (WebViewController.Link) -> Void,
        accepted: () async -> Void,
        declined: () async -> Void
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
    case requestPushNotificationsPermissions(
        conf: ConfirmationAlertConfiguration,
        accepted: () -> Void,
        declined: () -> Void
    )

    /// Indicating presentation priority of an alert.
    /// Based on comparing values we can decide whether an alert can be replaced with another alert.
    var presentationPriority: PresentationPriority {
        switch self {
        case .singleAction, .singleMediaUpgrade, .criticalError:
            return .highest
        case .confirmation, .liveObservationConfirmation, .requestPushNotificationsPermissions:
            return .high
        case .message, .systemAlert, .view, .leaveConversation:
            return .regular
        }
    }
}
