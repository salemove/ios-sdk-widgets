import UIKit

final class GliaPresenter {
    private let sceneProvider: SceneProvider?

    private lazy var window: UIWindow? = {
        if #available(iOS 13, *) {
            if let sceneProvider = sceneProvider {
                return sceneProvider.windowScene()?.windows.first { $0.isKeyWindow }
            } else {
                return UIApplication.shared.windows.first { $0.isKeyWindow }
            }
        } else {
            return UIApplication.shared.keyWindow
        }
    }()

    var topMostViewController: UIViewController {
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

    init(sceneProvider: SceneProvider?) {
        self.sceneProvider = sceneProvider
    }

    func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        topMostViewController.present(
            viewController,
            animated: animated,
            completion: completion
        )
    }

    func dismiss(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let presentingViewController = viewController.presentingViewController else {
            completion?()
            return
        }
        presentingViewController.dismiss(
            animated: animated,
            completion: completion
        )
    }
}
