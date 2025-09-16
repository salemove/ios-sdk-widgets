import UIKit

extension AlertViewController {
    func makeSingleActionAlertView(
        with conf: SingleActionAlertConfiguration,
        accessibilityIdentifier: String,
        actionTapped: @escaping () async -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message

        var buttonStyle = viewFactory.theme.alert.positiveAction
        buttonStyle.title = conf.buttonTitle ?? ""
        let button = AsyncActionButton(
            props: .init(
                style: buttonStyle,
                tap: .init { [weak self] in
                    self?.dismiss(animated: true)
                    await actionTapped()
                },
                accessibilityIdentifier: accessibilityIdentifier
            )
        )
        alertView.addActionView(button)

        return alertView
    }
}
