import UIKit

protocol ScreenShareOfferPresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func offerScreenShare(
        with conf: ScreenShareOfferAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    )
}

extension AlertPresenter {
    func offerScreenShare(
        with conf: ScreenShareOfferAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let alert = AlertViewController(
            kind: .screenShareOffer(conf, accepted: accepted, declined: declined),
            viewFactory: viewFactory
        )
        present(alert, animated: true, completion: nil)
    }
}
