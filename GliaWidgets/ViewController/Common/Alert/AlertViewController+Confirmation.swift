extension AlertViewController {
    func makeConfirmationAlertView(with strings: AlertConfirmationStrings,
                                   confirmed: @escaping () -> Void) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = strings.title
        alertView.message = strings.message
        alertView.showsPoweredBy = true
        alertView.actionsAxis = .horizontal

        let negativeButton = ActionButton(with: viewFactory.theme.alert.negativeAction)
        negativeButton.title = strings.negativeTitle
        negativeButton.tap = { [weak self] in
            self?.dismiss(animated: true)
        }
        let positiveButton = ActionButton(with: viewFactory.theme.alert.positiveAction)
        positiveButton.title = strings.positiveTitle
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
