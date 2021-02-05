extension AlertViewController {
    func makeConfirmationAlertView(with conf: ConfirmationAlertConfiguration,
                                   confirmed: @escaping () -> Void) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsPoweredBy = true
        alertView.actionsAxis = .horizontal

        let negativeButton = ActionButton(with: viewFactory.theme.alert.negativeAction)
        negativeButton.title = conf.negativeTitle
        negativeButton.tap = { [weak self] in
            self?.dismiss(animated: true)
        }
        let positiveButton = ActionButton(with: viewFactory.theme.alert.positiveAction)
        positiveButton.title = conf.positiveTitle
        positiveButton.tap = { [weak self] in
            self?.dismiss(animated: true) {
                confirmed()
            }
        }
        alertView.addActionView(negativeButton)
        alertView.addActionView(positiveButton)

        return alertView
    }
}
