import UIKit

extension AlertViewController {
    func makeMediaUpgradeAlertView(
        with conf: SingleMediaUpgradeAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.titleImage = conf.titleImage
        alertView.showsPoweredBy = conf.showsPoweredBy
        alertView.showsCloseButton = false

        let declineButton = ActionButton(with: viewFactory.theme.alert.negativeAction)
        declineButton.title = conf.decline
        declineButton.accessibilityIdentifier = "alert_negative_button"
        declineButton.tap = { [weak self] in
            self?.dismiss(animated: true) {
                declined()
            }
        }
        let acceptButton = ActionButton(with: viewFactory.theme.alert.positiveAction)
        acceptButton.title = conf.accept
        acceptButton.accessibilityIdentifier = "alert_positive_button"
        acceptButton.tap = { [weak self] in
            self?.dismiss(animated: true) {
                accepted()
            }
        }
        alertView.addActionView(declineButton)
        alertView.addActionView(acceptButton)

        return alertView
    }
}
