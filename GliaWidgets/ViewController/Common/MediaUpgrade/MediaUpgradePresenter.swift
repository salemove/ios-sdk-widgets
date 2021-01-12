import UIKit
import SalemoveSDK

protocol MediaUpgradePresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func offerMediaUpgrade(with strings: AlertTitleStrings,
                           mediaTypes: [MediaType],
                           accepted: @escaping (Int) -> Void,
                           declined: @escaping () -> Void)
}

extension AlertPresenter {
    func offerMediaUpgrade(with strings: AlertTitleStrings,
                           mediaTypes: [MediaType],
                           accepted: @escaping (Int) -> Void,
                           declined: @escaping () -> Void) {
        let alert = AlertViewController(kind: .mediaUpgrade(strings,
                                                            mediaTypes: mediaTypes,
                                                            accepted: accepted,
                                                            declined: declined),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }
}
