import UIKit

final class GliaPresenter {
    var environment: Environment
    var delayedTask: Task<Void, Error>?

    private var window: UIWindow? {
        // Retrieve all available windows.
        let allWindows = environment.appWindowsProvider.windows()
        // It is likely that there is one more window except BubbleWindow,
        // so we filter out `BubbleWindow` based windows.
        let nonBubbleWindows = allWindows.filter { !($0 is BubbleWindow) }
        // In case if there are no windows except `BubbleWindow`, we return
        // the one that is the key window, even if it is `BubbleWindow`.
        // There's still a chance to get proper window via `present(_:animated:completion:)`
        // method by using waiting strategy.
        if nonBubbleWindows.isEmpty {
            return allWindows.first(where: \.isKeyWindow)
        // If there's one or more non-BubbleWindow(s), we can search for one key
        // or one with non `nil` `rootViewController`,
        // but allow fallback to waiting strategy, just in case.
        } else {
            // First try to get non-bubble key window.
            let nonBubbleKeyWindow = nonBubbleWindows.first(where: \.isKeyWindow)
            // In case non-bubble key window is not found, substitute it with the one that has non-nil
            // root view controller, if there's one.
            let nonBubbleWindowWithRootViewController = nonBubbleWindows.first { $0.rootViewController != nil }
            // In case non-bubble window with root view controller is not found, fallback to any key window,
            // including bubble window. In such case, later during presentation this search
            // for non-bubble window will be repeated using waiting strategy.
            let fallbackKeyWindow = allWindows.first(where: \.isKeyWindow)
            return nonBubbleKeyWindow ??
                 nonBubbleWindowWithRootViewController ??
                 fallbackKeyWindow
        }
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
        if topMostViewController is BubbleViewController {
            environment.log.warning(
                """
                Attempt to present \(type(of: viewController)) on \(BubbleViewController.self).
                Falling back to waiting non-\(BubbleViewController.self) strategy.
                """
            )

            self.delayedTask?.cancel()
            self.delayedTask = Task { @MainActor in
                var timeWaited: UInt64 = 0
                // Attempt to wait until top most view controller (BubbleViewController)
                // is replaced with something else.
                while topMostViewController is BubbleViewController {
                    defer {
                        timeWaited += Self.waitingAttemptTimeNanoSeconds
                    }
                    // If task takes too much time, we return from the cycle,
                    // thus completing the work on the task.
                    guard timeWaited < Self.maxWaitingTimeNanoseconds else {
                        environment.log.error(
                            """
                            Waiting for non-\(BubbleViewController.self) has timed out after \(timeWaited) nanoseconds.
                            Unable to present \(type(of: viewController)) on \(BubbleViewController.self)
                            """)
                        return
                    }
                    // Suspend current task to try again later. This will not block main thread.
                    try await environment.taskSleep(Self.waitingAttemptTimeNanoSeconds)
                    // Let other processes to be worked on.
                    await Task.yield()
                }

                topMostViewController.present(
                    viewController,
                    animated: animated,
                    completion: completion
                )
            }

        } else {
            topMostViewController.present(
                viewController,
                animated: animated,
                completion: completion
            )
        }
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

extension GliaPresenter {
    // Time to wait before making another attempt to reach non-BubbleViewController.
    static let waitingAttemptTimeNanoSeconds: UInt64 = 100_000_000  // 0.1 sec.
    // Maximum time allowed to wait in total, reaching which will result in timeout.
    static let maxWaitingTimeNanoseconds = 3_000_000_000 // 3 seconds.

    struct Environment {
        var appWindowsProvider: AppWindowsProvider
        var log: CoreSdkClient.Logger
        var taskSleep: TaskSleep
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
