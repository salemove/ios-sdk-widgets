extension AlertViewController {
    func makeMediaUpgradeAlertView(with conf: SingleMediaUpgradeAlertConfiguration,
                                   accepted: @escaping () -> Void,
                                   declined: @escaping () -> Void) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.titleImage = conf.titleImage
        alertView.showsPoweredBy = true
        alertView.showsCloseButton = false
        alertView.actionsAxis = .horizontal

        let declineButton = ActionButton(with: viewFactory.theme.alert.negativeAction)
        declineButton.title = conf.decline
        declineButton.tap = { [weak self] in
            self?.dismiss(animated: true) {
                declined()
            }
        }
        let acceptButton = ActionButton(with: viewFactory.theme.alert.positiveAction)
        acceptButton.title = conf.accept
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
