import Foundation
import UIKit

extension CallVisualizer {
    final class Coordinator {
        init(
            viewFactory: ViewFactory,
            presenter: Presenter
        ) {
            self.viewFactory = viewFactory
            self.presenter = presenter
        }

        func offerScreenShare(
            with conf: ScreenShareOfferAlertConfiguration,
            accepted: @escaping () -> Void,
            declined: @escaping () -> Void
        ) {
            let alert = AlertViewController(
                kind: .screenShareOffer(conf, accepted: accepted, declined: declined),
                viewFactory: viewFactory
            )
            presenter.getInstance()?.present(alert, animated: true, completion: nil)
        }

        func presentCallVisualizerViewController() {
            presenter.getInstance()?.present(
                CallVisualizer.EngagementViewController(),
                animated: true
            )
        }

        // MARK: - Private

        private let viewFactory: ViewFactory
        private let presenter: Presenter
    }
}

extension CallVisualizer {
    public struct Presenter {
        init(presenter: @escaping () -> UIViewController?) {
            self.getInstance = presenter
        }

        let getInstance: () -> UIViewController?
    }
}

extension CallVisualizer.Presenter {
    static func topViewController(application: UIKitBased.UIApplication = .live) -> Self {
        .init {
            if var topController = application.shared().windows.first(where: { $0.isKeyWindow })?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
            return nil
        }
    }
}
