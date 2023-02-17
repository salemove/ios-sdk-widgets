import UIKit

extension AlertViewController {
    func makeScreenShareOfferAlertView(
        with conf: ScreenShareOfferAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.titleImage = conf.titleImage
        alertView.showsPoweredBy = conf.showsPoweredBy
        alertView.showsCloseButton = false

        let declineButton = ActionButton(
            props: .init(
                style: viewFactory.theme.alert.negativeAction,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: declined) },
                title: conf.decline
            )
        )

        let acceptButton = ActionButton(
            props: .init(
                style: viewFactory.theme.alert.positiveAction,
                tap: .init { [weak self] in self?.dismiss(animated: true, completion: accepted) },
                title: conf.accept
            )
        )
        alertView.addActionView(declineButton)
        alertView.addActionView(acceptButton)

        return alertView
    }
}
