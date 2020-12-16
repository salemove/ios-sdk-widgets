import UIKit

protocol AlertPresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func presentAlert(with strings: AlertMessageStrings,
                      dismissed: (() -> Void)?)
    func presentConfirmation(with strings: AlertConfirmationStrings,
                             confirmed: @escaping () -> Void)
}

extension AlertPresenter {
    func presentAlert(with strings: AlertMessageStrings,
                      dismissed: (() -> Void)? = nil) {
        let alert = AlertViewController(kind: .message(strings, dismissed: dismissed),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }

    func presentConfirmation(with strings: AlertConfirmationStrings,
                             confirmed: @escaping () -> Void) {
        let alert = AlertViewController(kind: .confirmation(strings, confirmed: confirmed),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }
}
