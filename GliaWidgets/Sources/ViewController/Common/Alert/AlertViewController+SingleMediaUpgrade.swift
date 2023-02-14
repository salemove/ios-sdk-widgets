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

        let declineButton = ActionButton(
            props: .init(
                style: viewFactory.theme.alert.negativeAction,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: declined) },
                title: conf.decline,
                accessibilityIdentifier: "alert_negative_button"
            )
        )

        let acceptButton = ActionButton(
            props: .init(
                style: viewFactory.theme.alert.positiveAction,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: accepted) },
                title: conf.accept,
                accessibilityIdentifier: "alert_positive_button"
            )
        )

        alertView.addActionView(declineButton)
        alertView.addActionView(acceptButton)

        return alertView
    }
}
