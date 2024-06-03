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

        var declineButtonStyle = viewFactory.theme.alert.negativeAction
        declineButtonStyle.title = conf.decline

        var acceptButtonStyle = viewFactory.theme.alert.positiveAction
        acceptButtonStyle.title = conf.accept

        let declineButton = ActionButton(
            props: .init(
                style: declineButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: declined) },
                accessibilityIdentifier: "alert_negative_button"
            )
        )

        let acceptButton = ActionButton(
            props: .init(
                style: acceptButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: accepted) },
                accessibilityIdentifier: "alert_positive_button"
            )
        )

        alertView.addActionView(declineButton)
        alertView.addActionView(acceptButton)

        return alertView
    }
}
