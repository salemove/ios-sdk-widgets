import SalemoveSDK

extension AlertViewController {
    func makeMediaUpgradeAlertView(with strings: AlertTitleStrings,
                                   mediaTypes: [MediaType],
                                   accepted: @escaping (Int) -> Void,
                                   declined: @escaping () -> Void) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = strings.title
        alertView.showsPoweredBy = true
        alertView.showsCloseButton = true
        alertView.actionsAxis = .vertical

        mediaTypes.enumerated().forEach({
            if let actionView = self.actionView(for: $0.element) {
                let index = $0.offset
                actionView.tap = { [weak self] in
                    self?.dismiss(animated: true) {
                        accepted(index)
                    }
                }
                alertView.addActionView(actionView)
            }
        })

        alertView.closeTapped = { [weak self] in
            self?.dismiss(animated: true) {
                declined()
            }
        }

        return alertView
    }

    private func actionView(for mediaType: MediaType) -> MediaUpgradeActionView? {
        switch mediaType {
        case .audio:
            return MediaUpgradeActionView(with: viewFactory.theme.alert.audioUpgradeAction)
        case .phone:
            return MediaUpgradeActionView(with: viewFactory.theme.alert.phoneUpgradeAction)
        default:
            return nil
        }
    }
}
