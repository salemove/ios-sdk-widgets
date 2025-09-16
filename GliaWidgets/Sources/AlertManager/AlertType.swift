import Foundation

enum AlertType {
    case message(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() async -> Void)?,
        onClose: () -> Void
    )
    case criticalError(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() async -> Void)?,
        onClose: () -> Void
    )
    case confirmation(
        conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: () async -> Void,
        onClose: () -> Void,
        dismissed: (() -> Void)?,
    )
    case leaveConversation(
        conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: () -> Void,
        declined: (() -> Void)?,
        onClose: () -> Void
    )
    case singleAction(
        conf: SingleActionAlertConfiguration,
        accessibilityIdentifier: String,
        actionTapped: () async -> Void,
        onClose: () -> Void
    )
    case singleMediaUpgrade(
        SingleMediaUpgradeAlertConfiguration,
        accepted: () -> Void,
        declined: () -> Void,
        onClose: () -> Void
    )
    case liveObservationConfirmation(
        ConfirmationAlertConfiguration,
        link1: (WebViewController.Link) -> Void,
        link2: (WebViewController.Link) -> Void,
        accepted: () async -> Void,
        declined: () async -> Void,
        onClose: () -> Void
    )
    case systemAlert(
        conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)?,
        onClose: () -> Void
    )
    case view(
        conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() -> Void)?,
        onClose: () -> Void
    )
    case requestPushNotificationsPermissions(
        conf: ConfirmationAlertConfiguration,
        accepted: () -> Void,
        declined: () -> Void,
        onClose: () -> Void
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

    var onCloseAction: () -> Void {
        switch self {
        case .message(_, _, _, let onClose),
                .criticalError(_, _, _, let onClose),
                .confirmation(_, _, _, _, let onClose),
                .leaveConversation(_, _, _, _, let onClose),
                .singleAction(_, _, _, let onClose),
                .singleMediaUpgrade(_, _, _, let onClose),
                .liveObservationConfirmation(_, _, _, _, _, let onClose),
                .systemAlert(_, _, let onClose),
                .view(_, _, _, let onClose),
                .requestPushNotificationsPermissions(_, _, _, let onClose):
            return onClose
        }
    }
}
