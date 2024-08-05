import UIKit

extension AlertViewController {
    func makeConfirmationAlertView(
        with conf: ConfirmationAlertConfiguration,
        accessibilityIdentifier: String,
        confirmed: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsPoweredBy = conf.showsPoweredBy
        alertView.accessibilityIdentifier = accessibilityIdentifier

        let alertStyle = viewFactory.theme.alert

        var negativeButtonStyle = alertStyle.negativeAction
        var positiveButtonStyle = alertStyle.positiveAction

        if conf.switchButtonBackgroundColors {
            negativeButtonStyle = alertStyle.positiveAction
            positiveButtonStyle = alertStyle.negativeAction
        }

        negativeButtonStyle.title = conf.negativeTitle ?? ""
        positiveButtonStyle.title = conf.positiveTitle ?? ""

        let negativeButton: ActionButton = ActionButton(
            props: .init(
                style: negativeButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) },
                accessibilityIdentifier: "alert_negative_button"
            )
        )
        let positiveButton = ActionButton(
            props: ActionButton.Props(
                style: positiveButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) { confirmed() } },
                accessibilityIdentifier: "alert_positive_button"
            )
        )

        alertView.addActionView(negativeButton)
        alertView.addActionView(positiveButton)

        return alertView
    }
}
