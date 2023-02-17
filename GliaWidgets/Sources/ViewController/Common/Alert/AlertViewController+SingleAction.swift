import UIKit

extension AlertViewController {
    func makeSingleActionAlertView(
        with conf: SingleActionAlertConfiguration,
        accessibilityIdentifier: String,
        actionTapped: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message

        let buttonStyle = viewFactory.theme.alert.positiveAction

        let button = ActionButton(
            props: .init(
                style: buttonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true); actionTapped() },
                title: conf.buttonTitle ?? "",
                accessibilityIdentifier: accessibilityIdentifier
            )
        )
        alertView.addActionView(button)

        return alertView
    }
}
