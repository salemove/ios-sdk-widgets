extension AlertViewController {
    func makeMessageAlertView(with strings: AlertMessageStrings,
                              dismissed: (() -> Void)?) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = strings.title
        alertView.message = strings.message
        alertView.showsCloseButton = true
        alertView.closeTapped = { [weak self] in
            self?.dismiss(animated: true) {
                dismissed?()
            }
        }
        return alertView
    }
}
