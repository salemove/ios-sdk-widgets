import UIKit
import Foundation

/// The `AlertManager` class is responsible for managing and presenting 
/// alert views within an application. It handles the presentation of alerts
/// globally or within specific view controllers, supports theme overrides,
/// and ensures that alerts are properly replaced and cleaned up as needed.
final class AlertManager {
    /// The environment configuration for the alert manager, 
    /// including logging and application references.
    private let environment: Environment

    /// The composer that assembles alert types based on input and placement.
    private var composer: AlertTypeComposer

    /// The currently displayed alert, if any.
    private var currentAlert: AlertInputType?

    /// The view controller responsible for displaying the alert.
    private var alertViewController: AlertViewController?

    /// The window used to present global alerts.
    private var alertWindow: UIWindow?

    /// Flag used internally to specify if view controller presentation has to be animated.
    /// Useful to be set to false during unit tests to avoid dealing with delays, thus slow tests.
    private var isViewControllerPresentationAnimated = true

    /// - Parameters:
    ///   - environment: The environment configuration for the alert manager.
    ///   - viewFactory: The view factory responsible for creating the alert views.
    ///
    init(environment: Environment) {
        self.environment = environment
        composer = .init(
            environment: .create(with: environment),
            theme: environment.viewFactory.theme
        )
    }
}

// MARK: - Internal Methods
extension AlertManager {
    /// Presents an alert based on the specified placement and input type.
    /// - Parameters:
    ///   - placement: The placement of the alert (global or in a specific view controller).
    ///   - input: The input type of the alert.
    ///
    func present(
        in placement: AlertPlacement,
        as input: AlertInputType
    ) {
        guard input != currentAlert, let alertType = try? composer.composeAlert(input: input) else { return }

        switch placement {
        case .global:
            presentGlobally(
                type: alertType,
                input: input
            )
        case let .root(viewController):
            presentInRoot(
                type: alertType,
                input: input,
                viewController: viewController
            )
        }
    }

    /// Overrides the current theme with a new theme.
    /// - Parameters:
    ///   - newTheme: The new theme to apply.
    ///
    func overrideTheme(_ newTheme: Theme) {
        self.composer.overrideTheme(with: newTheme)
        self.environment.viewFactory.overrideTheme(with: newTheme)
    }

    func dismissCurrentAlert() {
        guard let alertViewController = alertViewController else { return }
        alertViewController.dismiss(animated: true)
        cleanup()
    }
}

// MARK: - Private Methods
private extension AlertManager {
    /// Presents an alert in the root view controller.
    /// - Parameters:
    ///   - type: The type of the alert.
    ///   - input: The input type of the alert.
    ///   - viewController: The view controller in which to present the alert.
    ///
    func presentInRoot(
        type: AlertType,
        input: AlertInputType,
        viewController: UIViewController
    ) {
        let alertViewController = createAlertViewController(type: type)
        alertViewController.onDismissed = { [weak self] in
            type.onCloseAction()
            self?.cleanup()
        }
        guard isAlertReplacable(offer: alertViewController) else { return }
        self.alertViewController = alertViewController
        self.currentAlert = input
        switch type {
        case let .systemAlert(conf, cancelled, _):
            let alert = createSystemAlert(
                conf: conf,
                cancelled: cancelled
            )
            viewController.present(
                alert,
                animated: isViewControllerPresentationAnimated,
                completion: nil
            )
        case .view:
            viewController.insertChild(alertViewController)
            alertViewController.view.translatesAutoresizingMaskIntoConstraints = false
            // Disabled interaction is needed to pass touches to the view behind
            alertViewController.view.isUserInteractionEnabled = false
            NSLayoutConstraint.activate([
                viewController.view.topAnchor.constraint(equalTo: alertViewController.view.topAnchor),
                viewController.view.bottomAnchor.constraint(equalTo: alertViewController.view.bottomAnchor),
                viewController.view.leadingAnchor.constraint(equalTo: alertViewController.view.leadingAnchor),
                viewController.view.trailingAnchor.constraint(equalTo: alertViewController.view.trailingAnchor)
            ])
        default:
            let completion: () -> Void = { [isViewControllerPresentationAnimated] in
                viewController.present(
                    alertViewController,
                    animated: isViewControllerPresentationAnimated
                )
            }
            guard let presented = viewController.presentedViewController as? Replaceable else {
                completion()
                return
            }
            presented.dismiss(
                animated: true,
                completion: completion
            )
        }
    }

    /// Presents an alert globally in a new window.
    /// - Parameters:
    ///   - type: The type of the alert.
    ///   - input: The input type of the alert.
    ///
    func presentGlobally(
        type: AlertType,
        input: AlertInputType
    ) {
        let alertViewController = createAlertViewController(type: type)
        alertViewController.onDismissed = { [weak self] in
            type.onCloseAction()
            self?.cleanup()
        }
        guard isAlertReplacable(offer: alertViewController) else { return }
        self.alertViewController = alertViewController
        self.currentAlert = input
        createAlertWindow()
        guard let alertWindow = alertWindow else { return }
        alertWindow.isHidden = false
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(
            alertViewController,
            animated: isViewControllerPresentationAnimated,
            completion: nil
        )
    }

    func createAlertViewController(type: AlertType) -> AlertViewController {
        .init(type: type, viewFactory: environment.viewFactory)
    }

    func createSystemAlert(
        conf: SettingsAlertConfiguration,
        cancelled: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: conf.title,
            message: conf.message,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(
            title: conf.cancelTitle,
            style: .cancel,
            handler: { _ in
                cancelled?()
            }
        )
        let settings = UIAlertAction(
            title: conf.settingsTitle,
            style: .default,
            handler: { _ in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsURL)
            }
        )
        alert.addAction(cancel)
        alert.addAction(settings)

        return alert
    }

    func isAlertReplacable(offer: Replaceable) -> Bool {
        alertViewController?.isReplaceable(with: offer) ?? true
    }

    func cleanup() {
        alertViewController = nil
        alertWindow?.isHidden = true
        alertWindow = nil
        currentAlert = nil
    }
}

// MARK: - KeyWindow
private extension AlertManager {
    func createAlertWindow() {
        if let windowScene = windowScene() {
            alertWindow = UIWindow(windowScene: windowScene)
        } else {
            alertWindow = UIWindow(frame: UIScreen.main.bounds)
        }

        alertWindow?.windowLevel = UIWindow.Level.alert + 1
        alertWindow?.rootViewController = UIViewController()
    }

    func windowScene() -> UIWindowScene? {
        environment.uiApplication.connectionScenes()
            .compactMap { $0 as? UIWindowScene }
            .first
    }
}

#if DEBUG
extension AlertManager {
    /// Enables and disables presentation animation for view controller for unit testing
    func setViewControllerPresentationAnimated(_ isAnimated: Bool) {
        self.isViewControllerPresentationAnimated = isAnimated
    }
}
#endif
