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

        let negativeButtonStyle = viewFactory.theme.alert.negativeAction
        let positiveButtonStyle = viewFactory.theme.alert.positiveAction

        let negativeButton: ActionButton
        let positiveButton: ActionButton

        if conf.switchButtonBackgroundColors {
            negativeButton = ActionButton(with: positiveButtonStyle)
            positiveButton = ActionButton(with: negativeButtonStyle)
        } else {
            negativeButton = ActionButton(with: negativeButtonStyle)
            positiveButton = ActionButton(with: positiveButtonStyle)
        }

        negativeButton.title = conf.negativeTitle
        negativeButton.accessibilityIdentifier = "alert_negative_button"
        negativeButton.tap = { [weak self] in
            self?.dismiss(animated: true)
        }
        positiveButton.title = conf.positiveTitle
        positiveButton.accessibilityIdentifier = "alert_positive_button"
        positiveButton.tap = { [weak self] in
            self?.dismiss(animated: true) {
                confirmed()
            }
        }
        alertView.addActionView(negativeButton)
        alertView.addActionView(positiveButton)

        return alertView
    }
}
