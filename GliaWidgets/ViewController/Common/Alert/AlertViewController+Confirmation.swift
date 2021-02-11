extension AlertViewController {
    func makeConfirmationAlertView(with conf: ConfirmationAlertConfiguration,
                                   confirmed: @escaping () -> Void) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsPoweredBy = true
        alertView.actionsAxis = .horizontal

        var negativeButtonStyle = viewFactory.theme.alert.negativeAction
        var positiveButtonStyle = viewFactory.theme.alert.positiveAction

        if conf.switchButtonBackgroundColors {
            let negativeColor = negativeButtonStyle.backgroundColor
            negativeButtonStyle.backgroundColor = positiveButtonStyle.backgroundColor
            positiveButtonStyle.backgroundColor = negativeColor
        }

        let negativeButton = ActionButton(with: negativeButtonStyle)
        negativeButton.title = conf.negativeTitle
        negativeButton.tap = { [weak self] in
            self?.dismiss(animated: true)
        }
        let positiveButton = ActionButton(with: positiveButtonStyle)
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
