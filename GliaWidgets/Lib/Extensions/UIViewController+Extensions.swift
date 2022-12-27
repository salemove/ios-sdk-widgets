import UIKit

extension UIViewController {
    func insertChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: self)
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
