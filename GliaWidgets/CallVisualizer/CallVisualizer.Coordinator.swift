import Foundation
import UIKit

extension CallVisualizer {
    final class Coordinator {

        init(
            viewFactory: ViewFactory
        ) {
            self.viewFactory = viewFactory
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
            presenter.present(alert, animated: true, completion: nil)
        }

        func presentCallVisualizerViewController() {

            presenter.present(
                CallVisualizer.EngagementViewController(),
                animated: true
            )
        }

        // MARK: - Private

        private let viewFactory: ViewFactory

        private var presenter: UIViewController {
            if var topController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }

                return topController
            }

            return .init()
        }
    }
}
