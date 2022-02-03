import UIKit

protocol MediaUpgradePresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func offerMediaUpgrade(
        with conf: SingleMediaUpgradeAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    )
}

extension AlertPresenter {
    func offerMediaUpgrade(
        with conf: SingleMediaUpgradeAlertConfiguration,
        accepted: @escaping () -> Void,
        declined: @escaping () -> Void
    ) {
        let alert = AlertViewController(
            kind: .singleMediaUpgrade(conf,
                                      accepted: accepted,
                                      declined: declined),
            viewFactory: viewFactory
        )
        present(alert, animated: true, completion: nil)
    }
}
