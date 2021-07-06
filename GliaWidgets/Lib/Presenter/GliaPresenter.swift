import UIKit
internal final class GliaPresenter {
    private var window: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    internal var root: UIViewController {
        guard let window = window else {
            fatalError("Could not find key UIWindow to present on")
        }

        guard var presenter = window.rootViewController else {
            fatalError("Could not find UIViewController to present on")
        }

        while let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }

        return presenter
    }

    internal func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        root.present(viewController, animated: animated, completion: completion)
    }

    internal func dismiss(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        viewController.presentingViewController?.dismiss(animated: animated, completion: completion)
    }
}
