import Foundation

extension AlertViewController {
    func makeRequestPNPermissionsAlertView(
        with conf: ConfirmationAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsPoweredBy = conf.showsPoweredBy
        alertView.showsCloseButton = false

        let alertStyle = viewFactory.theme.alert
        var declineButtonStyle = alertStyle.negativeAction
        declineButtonStyle.title = conf.negativeTitle

        var acceptButtonStyle = alertStyle.positiveAction
        acceptButtonStyle.title = conf.positiveTitle

        let declineButton = ActionButton(
            props: .init(
                style: declineButtonStyle,
                tap: .sync(
                    .init { [weak self] in self?.dismiss(animated: true, completion: declined) }
                )
            )
        )

        let acceptButton = ActionButton(
            props: .init(
                style: acceptButtonStyle,
                tap: .sync(
                    .init { [weak self] in self?.dismiss(animated: true, completion: accepted) }
                )
            )
        )
        alertView.addActionView(declineButton)
        alertView.addActionView(acceptButton)

        return alertView
    }
}
