extension AlertViewController {
    func makeSingleActionAlertView(
        with conf: SingleActionAlertConfiguration,
        actionTapped: @escaping () -> Void
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.actionsAxis = .horizontal

        let buttonStyle = viewFactory.theme.alert.positiveAction

        let button = ActionButton(with: buttonStyle)
        button.title = conf.buttonTitle
        button.tap = { [weak self] in
            self?.dismiss(animated: true)
            actionTapped()
        }
        alertView.addActionView(button)

        return alertView
    }
}
