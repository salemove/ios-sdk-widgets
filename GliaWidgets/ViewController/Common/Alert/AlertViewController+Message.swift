extension AlertViewController {
    func makeMessageAlertView(with conf: MessageAlertConfiguration,
                              dismissed: (() -> Void)?) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsCloseButton = true
        alertView.closeTapped = { [weak self] in
            self?.dismiss(animated: true) {
                dismissed?()
            }
        }
        return alertView
    }
}
