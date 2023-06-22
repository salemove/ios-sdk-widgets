import UIKit

protocol MediaUpgradePresenter: DismissalAndPresentationController where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func offerMediaUpgrade(
        with conf: SingleMediaUpgradeAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    )
}

extension MediaUpgradePresenter {
    func offerMediaUpgrade(
        with conf: SingleMediaUpgradeAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let alert = AlertViewController(
            kind: .singleMediaUpgrade(
                conf,
                accepted: accepted,
                declined: declined
            ),
            viewFactory: self.viewFactory
        )
        replacePresentedOfferIfPossible(with: alert)
    }
}
