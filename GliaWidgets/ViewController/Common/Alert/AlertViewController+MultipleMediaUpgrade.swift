import SalemoveSDK

extension AlertViewController {
    func makeMediaUpgradeAlertView(with conf: MultipleMediaUpgradeAlertConfiguration,
                                   mediaTypes: [MediaType],
                                   accepted: @escaping (Int) -> Void,
                                   declined: @escaping () -> Void) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.showsPoweredBy = true
        alertView.showsCloseButton = true
        alertView.actionsAxis = .vertical

        mediaTypes.enumerated().forEach({
            if let actionView = self.actionView(for: $0.element, from: conf) {
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

    private func actionView(for mediaType: MediaType, from conf: MultipleMediaUpgradeAlertConfiguration) -> MediaUpgradeActionView? {
        switch mediaType {
        case .audio:
            return MediaUpgradeActionView(with: conf.audioUpgradeAction)
        case .phone:
            return MediaUpgradeActionView(with: conf.phoneUpgradeAction)
        default:
            return nil
        }
    }
}
