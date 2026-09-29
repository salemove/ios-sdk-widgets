import UIKit

final class GliaPresenter {
    var environment: Environment

    var window: UIWindow? {
        // Retrieve all available windows.
        let allWindows = environment.appWindowsProvider.windows()
        // It is likely that there is one more window except SDK-owned ones,
        // so we filter out `GliaOwnedWindow` based windows.
        let nonSDKWindows = allWindows.filter { !($0 is GliaOwnedWindow) }
        // In case if there are no windows except SDK-owned ones, we return
        // the one that is the key window, even if it is SDK-owned.
        // In case if there are no key windows, we take first one with
        // non `nil` `rootViewController`.
        if nonSDKWindows.isEmpty {
            return Self.windowForPresenting(from: allWindows) ?? allWindows.first
        } else {
            // First try to get non-SDK-owned key window.
            // In case non-SDK-owned key window is not found, substitute it with the one that has non-nil
            // root view controller, if there's one.
            let nonSDKWindow = Self.windowForPresenting(from: nonSDKWindows)
            // In case non-SDK-owned window with root view controller is not found, fallback to any key window,
            // including SDK-owned ones.
            let fallbackWindow = Self.windowForPresenting(from: allWindows)
            return nonSDKWindow ?? fallbackWindow ?? allWindows.first
        }
    }

    static func windowForPresenting(from windows: [UIWindow]) -> UIWindow? {
        // First try to get key window, then try to get the one with non-nil view controller.
        windows.first(where: \.isKeyWindow) ?? windows.first(where: { $0.rootViewController != nil })
    }

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

    init(environment: Environment) {
        self.environment = environment
    }

    func present(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        let presentingController = topMostViewController
        if presentingController is BubbleViewController {
            environment.log.warning(
                """
                Attempt to present \(type(of: viewController)) on \(BubbleViewController.self).
                """
            )
        }
        if viewController === presentingController {
            environment.log.warning(
                """
                Attempt to present the same instance of \(presentingController.self).
                """
            )
            return
        }
        presentingController.present(
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
        environment.dismissManager.dismiss(
            presentingViewController,
            animated: animated,
            completion: completion
        )
    }
}

extension GliaPresenter {
    // DismissManaged is used to control dismiss completion delayed by CoreAnimation.
    struct DismissManager {
        var dismissViewControllerAnimateWithCompletion: (
            _ viewController: UIViewController,
            _ animated: Bool,
            _ completion: (() -> Void)?
        ) -> Void

        func dismiss(
            _ viewController: UIViewController,
            animated: Bool,
            completion: (() -> Void)? = nil
        ) {
            dismissViewControllerAnimateWithCompletion(viewController, animated, completion)
        }
    }
}

extension GliaPresenter {
    struct AppWindowsProvider {
        var windows: () -> [UIWindow]
    }
}

extension GliaPresenter.AppWindowsProvider {
    init(uiApplication: UIKitBased.UIApplication, sceneProvider: SceneProvider?) {
        self.windows = { sceneProvider?.windowScene()?.windows ?? uiApplication.windows() }
    }
}

#if DEBUG
extension GliaPresenter.Environment {
    static let mock = Self(
        appWindowsProvider: .mock,
        log: .mock,
        dismissManager: .init { _, _, _ in }
    )
}

extension GliaPresenter.AppWindowsProvider {
    static let mock = Self(windows: { [] })
}
#endif
