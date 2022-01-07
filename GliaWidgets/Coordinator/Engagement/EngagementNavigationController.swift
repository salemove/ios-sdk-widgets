import UIKit

final class EngagementNavigationController: UINavigationController {}

extension EngagementNavigationController {
    private static let duration: CFTimeInterval = 0.2

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            let transition = CATransition()

            transition.duration = type(of: self).duration
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

            transition.duration = type(of: self).duration
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

            transition.duration = type(of: self).duration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .push
            transition.subtype = .fromLeft

            view.layer.add(transition, forKey: nil)
        }

        return super.popToRootViewController(animated: false)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if animated {
            let transition = CATransition()

            transition.duration = type(of: self).duration
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade

            view.layer.add(transition, forKey: nil)
        }

        super.setViewControllers(viewControllers, animated: false)
    }
}
