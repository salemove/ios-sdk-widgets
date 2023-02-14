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

        let negativeButton: ActionButton = ActionButton(
            props: .init(
                style: negativeButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) },
                title: conf.negativeTitle ?? "",
                accessibilityIdentifier: "alert_negative_button"
            )
        )
        let positiveButton = ActionButton(
            props: ActionButton.Props(
                style: positiveButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true) { confirmed() } },
                title: conf.positiveTitle ?? "",
                accessibilityIdentifier: "alert_positive_button"
            )
        )

        if conf.switchButtonBackgroundColors {
            negativeButton.props.style = positiveButtonStyle
            positiveButton.props.style = negativeButtonStyle
        }
        alertView.addActionView(negativeButton)
        alertView.addActionView(positiveButton)

        return alertView
    }
}
