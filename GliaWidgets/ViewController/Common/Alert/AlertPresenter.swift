import UIKit

protocol AlertPresenter where Self: UIViewController {
    var viewFactory: ViewFactory { get }
    func alert(with content: AlertMessageContent, animated: Bool)
}

extension AlertPresenter {
    func alert(with content: AlertMessageContent, animated: Bool = true) {
        let alert = AlertViewController(kind: .message(content),
                                        viewFactory: viewFactory)
        present(alert, animated: true, completion: nil)
    }
}
