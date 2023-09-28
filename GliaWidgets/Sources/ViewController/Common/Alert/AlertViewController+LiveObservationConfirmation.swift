import UIKit

extension AlertViewController {
    func makeLiveObservationAlertView(
        with conf: ConfirmationAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsPoweredBy = conf.showsPoweredBy
        alertView.showsCloseButton = false

        var declineButtonStyle = viewFactory.theme.alert.negativeAction
        declineButtonStyle.title = conf.negativeTitle ?? ""

        var acceptButtonStyle = viewFactory.theme.alert.positiveAction
        acceptButtonStyle.title = conf.positiveTitle ?? ""

        let declineButton = ActionButton(
            props: .init(
                style: declineButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: declined) }
            )
        )

        let acceptButton = ActionButton(
            props: .init(
                style: acceptButtonStyle,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: accepted) }
            )
        )
        alertView.addActionView(declineButton)
        alertView.addActionView(acceptButton)

        return alertView
    }
}
