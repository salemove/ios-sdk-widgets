import UIKit

protocol AlertPresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }

    func presentAlert(with texts: AlertMessageTexts)
    func presentConfirmation(with texts: AlertConfirmationTexts,
                             confirmed: @escaping () -> Void)
}

extension AlertPresenter {
    func presentAlert(with texts: AlertMessageTexts) {
        let alert = AlertViewController(kind: .message(texts),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }

    func presentConfirmation(with texts: AlertConfirmationTexts,
                             confirmed: @escaping () -> Void) {
        let alert = AlertViewController(kind: .confirmation(texts, confirmed: confirmed),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }
}
