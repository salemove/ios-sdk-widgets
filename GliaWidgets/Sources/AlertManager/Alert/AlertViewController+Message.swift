import UIKit

extension AlertViewController {
    func makeMessageAlertView(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (() async -> Void)?
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsCloseButton = conf.shouldShowCloseButton
        alertView.closeTapped = { [weak self] in
            self?.dismiss(animated: true)
            await dismissed?()
        }
        alertView.accessibilityIdentifier = accessibilityIdentifier
        return alertView
    }
}
