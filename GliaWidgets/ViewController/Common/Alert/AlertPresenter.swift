import UIKit

protocol AlertPresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }
    func alert(with texts: AlertMessageTexts, animated: Bool)
}

extension AlertPresenter {
    func alert(with texts: AlertMessageTexts, animated: Bool = true) {
        let alert = AlertViewController(kind: .message(texts),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }
}
