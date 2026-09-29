import UIKit

class NavigationController: UINavigationController {
    /// When set, alerts raised by the screens on this stack are presented within
    /// this controller's bounds instead of over the whole window. Used by the iPad
    /// side panel so alerts dim the panel only, leaving the host app untouched.
    /// `UINavigationController` already defines a presentation context by default,
    /// so this flag is what actually opts a stack into the contained behaviour.
    var confinesAlertsToOwnBounds = false

    private let transitionDuration: CFTimeInterval = 0.3

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            let transition = CATransition()
            transition.duration = transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromRight
            view.layer.add(transition, forKey: nil)
        }

        super.pushViewController(viewController, animated: false)
    }

    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        if animated {
            let transition = CATransition()
            transition.duration = transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromLeft
            view.layer.add(transition, forKey: nil)
        }

        return super.popViewController(animated: false)
    }

    @discardableResult
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            let transition = CATransition()
            transition.duration = transitionDuration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromLeft
            view.layer.add(transition, forKey: nil)
        }

        return super.popToRootViewController(animated: false)
    }
}
