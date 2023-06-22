import UIKit

protocol ScreenShareOfferPresenter: DismissalAndPresentationController where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func offerScreenShare(
        with conf: ScreenShareOfferAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    )
}

extension ScreenShareOfferPresenter {
    func offerScreenShare(
        with conf: ScreenShareOfferAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let alert = AlertViewController(
            kind: .screenShareOffer(conf, accepted: accepted, declined: declined),
            viewFactory: self.viewFactory
        )
        replacePresentedOfferIfPossible(with: alert)
    }
}
