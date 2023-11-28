import UIKit

extension AlertViewController {
    func makeLiveObservationAlertView(
        with conf: ConfirmationAlertConfiguration,
        link: @escaping (WebViewController.Link) -> Void,
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
        declineButtonStyle.title = conf.negativeTitle ?? ""

        var acceptButtonStyle = alertStyle.positiveAction
        acceptButtonStyle.title = conf.positiveTitle ?? ""

        if let firstLinkButton = linkButton(
            for: conf.firstLinkButtonUrl,
            style: alertStyle.firstLinkAction,
            action: .init(closure: link)
        ) {
            alertView.addLinkButton(firstLinkButton)
        }

        if let secondLinkButton = linkButton(
            for: conf.secondLinkButtonUrl,
            style: alertStyle.secondLinkAction,
            action: .init(closure: link)
        ) {
            alertView.addLinkButton(secondLinkButton)
        }

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

    private func linkButton(
        for url: String?,
        style: ActionButtonStyle,
        action: Command<(WebViewController.Link)>
    ) -> ActionButton? {
        guard !style.title.isEmpty,
              let buttonUrlString = url,
              let buttonUrl = URL(string: buttonUrlString)
        else { return nil }
        return ActionButton(
            props: .init(
                style: style,
                height: 34,
                tap: .init { action((title: style.title, url: buttonUrl)) }
            )
        )
    }
}
