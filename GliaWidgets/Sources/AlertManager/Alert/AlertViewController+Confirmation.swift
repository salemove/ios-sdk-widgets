import UIKit

extension AlertViewController {
    func makeLeaveConversationAlertView(
        with conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: @escaping () -> Void,
        declined: (() -> Void)?
    ) -> AlertView {
        let alertView = makeAlertView(
            with: conf,
            accessibilityIdentifier: accessibilityIdentifier,
            confirmed: confirmed
        )
        let alertStyle = viewFactory.theme.alert
        var negativeButtonStyle = alertStyle.negativeNeutralAction
        var positiveButtonStyle = alertStyle.positiveAction

        if conf.switchButtonBackgroundColors {
            negativeButtonStyle = alertStyle.positiveAction
            positiveButtonStyle = alertStyle.negativeNeutralAction
        }

        negativeButtonStyle.title = conf.negativeTitle
        positiveButtonStyle.title = conf.positiveTitle

        let confirmButton: ActionButton = ActionButton(
            props: .init(
                style: negativeButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) { confirmed() } },
                accessibilityIdentifier: "alert_negative_button"
            )
        )
        let declineButton = ActionButton(
            props: ActionButton.Props(
                style: positiveButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) { declined?() } },
                accessibilityIdentifier: "alert_positive_button"
            )
        )
        alertView.addActionView(declineButton)
        alertView.addActionView(confirmButton)
        return alertView
    }

    func makeConfirmationAlertView(
        with conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: @escaping () -> Void
    ) -> AlertView {
        let alertView = makeAlertView(
            with: conf,
            accessibilityIdentifier: accessibilityIdentifier,
            confirmed: confirmed
        )
        let alertStyle = viewFactory.theme.alert
        var negativeButtonStyle = alertStyle.negativeAction
        var positiveButtonStyle = alertStyle.positiveAction

        if conf.switchButtonBackgroundColors {
            negativeButtonStyle = alertStyle.positiveAction
            positiveButtonStyle = alertStyle.negativeAction
        }

        negativeButtonStyle.title = conf.negativeTitle
        positiveButtonStyle.title = conf.positiveTitle

        let declineButton: ActionButton = ActionButton(
            props: .init(
                style: negativeButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) },
                accessibilityIdentifier: "alert_negative_button"
            )
        )
        let confirmButton = ActionButton(
            props: ActionButton.Props(
                style: positiveButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) { confirmed() } },
                accessibilityIdentifier: "alert_positive_button"
            )
        )

        alertView.addActionView(declineButton)
        alertView.addActionView(confirmButton)
        return alertView
    }

    private func makeAlertView(
        with conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsPoweredBy = conf.showsPoweredBy
        alertView.accessibilityIdentifier = accessibilityIdentifier

        return alertView
    }
}
