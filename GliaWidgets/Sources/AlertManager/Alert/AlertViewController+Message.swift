import UIKit

extension AlertViewController {
    func makeMessageAlertView(
        with conf: MessageAlertConfiguration,
        accessibilityIdentifier: String?,
        dismissed: (@MainActor () async -> Void)?
    ) -> AlertView {
        let alertView = viewFactory.makeAlertView()
        alertView.title = conf.title
        alertView.message = conf.message
        alertView.showsCloseButton = conf.shouldShowCloseButton
        alertView.closeTapped = { [weak self] in
            await self?.dismissThenPerform {
                await dismissed?()
            }
        }
        alertView.accessibilityIdentifier = accessibilityIdentifier
        return alertView
    }
}
