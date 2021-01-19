import UIKit
import SalemoveSDK

protocol MediaUpgradePresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func offerMediaUpgrade(with conf: MediaUpgradeAlertConf,
                           mediaTypes: [MediaType],
                           accepted: @escaping (Int) -> Void,
                           declined: @escaping () -> Void)
    func offerAudioUpgrade(with conf: AudioUpgradeAlertConf,
                           accepted: @escaping () -> Void,
                           declined: @escaping () -> Void)
}

extension AlertPresenter {
    func offerMediaUpgrade(with conf: MediaUpgradeAlertConf,
                           mediaTypes: [MediaType],
                           accepted: @escaping (Int) -> Void,
                           declined: @escaping () -> Void) {
        let alert = AlertViewController(kind: .mediaUpgrade(conf,
                                                            mediaTypes: mediaTypes,
                                                            accepted: accepted,
                                                            declined: declined),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }

    func offerAudioUpgrade(with conf: AudioUpgradeAlertConf,
                           accepted: @escaping () -> Void,
                           declined: @escaping () -> Void) {
        let alert = AlertViewController(kind: .audioUpgrade(conf,
                                                            accepted: accepted,
                                                            declined: declined),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }
}
