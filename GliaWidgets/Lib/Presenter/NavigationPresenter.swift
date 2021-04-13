import UIKit

class NavigationPresenter {
    private(set) var navigationController: UINavigationController

    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func push(_ vc: UIViewController, animated: Bool = true, replacingLast: Bool = false) {
        if replacingLast {
            let vcs = Array(viewControllers.dropLast()) + [vc]
            setViewControllers(vcs, animated: animated)
        } else {
            navigationController.pushViewController(vc, animated: animated)
        }
    }

    func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }

    func pop(to vc: UIViewController, animated: Bool = true) {
        navigationController.popToViewController(vc, animated: animated)
    }

    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func present(_ vc: UIViewController, animated: Bool = true) {
        navigationController.present(vc, animated: animated, completion: nil)
    }

    func dismiss(animated: Bool = true) {
        navigationController.dismiss(animated: animated, completion: nil)
    }

    func setViewControllers(_ vcs: [UIViewController], animated: Bool = true) {
        navigationController.setViewControllers(vcs, animated: animated)
    }

    var viewControllers: [UIViewController] {
        return navigationController.viewControllers
    }
}
