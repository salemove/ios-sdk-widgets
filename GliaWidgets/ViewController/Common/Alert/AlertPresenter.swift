import UIKit

protocol AlertPresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func presentAlert(with conf: MessageAlertConf,
                      dismissed: (() -> Void)?)
    func presentConfirmation(with conf: ConfirmationAlertConf,
                             confirmed: @escaping () -> Void)
}

extension AlertPresenter {
    func presentAlert(with conf: MessageAlertConf,
                      dismissed: (() -> Void)? = nil) {
        let alert = AlertViewController(kind: .message(conf, dismissed: dismissed),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }

    func presentConfirmation(with conf: ConfirmationAlertConf,
                             confirmed: @escaping () -> Void) {
        let alert = AlertViewController(kind: .confirmation(conf, confirmed: confirmed),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }
}
