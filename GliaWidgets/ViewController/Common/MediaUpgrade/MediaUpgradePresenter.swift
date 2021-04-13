import UIKit
import SalemoveSDK

protocol MediaUpgradePresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func offerMediaUpgrade(with conf: MultipleMediaUpgradeAlertConfiguration,
                           mediaTypes: [MediaType],
                           accepted: @escaping (Int) -> Void,
                           declined: @escaping () -> Void)
    func offerMediaUpgrade(with conf: SingleMediaUpgradeAlertConfiguration,
                           accepted: @escaping () -> Void,
                           declined: @escaping () -> Void)
}

extension AlertPresenter {
    func offerMediaUpgrade(with conf: MultipleMediaUpgradeAlertConfiguration,
                           mediaTypes: [MediaType],
                           accepted: @escaping (Int) -> Void,
                           declined: @escaping () -> Void) {
        let alert = AlertViewController(
            kind: .multipleMediaUpgrade(conf,
                                        mediaTypes: mediaTypes,
                                        accepted: accepted,
                                        declined: declined),
            viewFactory: viewFactory
        )
        present(alert, animated: true, completion: nil)
    }

    func offerMediaUpgrade(with conf: SingleMediaUpgradeAlertConfiguration,
                           accepted: @escaping () -> Void,
                           declined: @escaping () -> Void) {
        let alert = AlertViewController(
            kind: .singleMediaUpgrade(conf,
                                      accepted: accepted,
                                      declined: declined),
            viewFactory: viewFactory
        )
        present(alert, animated: true, completion: nil)
    }
}
