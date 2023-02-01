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
            self.bubbleView = viewFactory.makeBubbleView()

            bubbleView.tap = { [weak self] in
                self?.presentCallVisualizerViewController()
            }
            bubbleView.pan = { [weak self] translation in
                self?.updateBubblePosition(translation: translation)
            }
        }

        func offerScreenShare(
            from operators: [CoreSdkClient.Operator],
            configuration: ScreenShareOfferAlertConfiguration,
            accepted: @escaping () -> Void,
            declined: @escaping () -> Void
        ) {
            let alert = AlertViewController(
                kind: .screenShareOffer(
                    configuration.withOperatorName(operators.compactMap { $0.name }.joined()),
                    accepted: { [weak self] in
                        accepted()
                        self?.createBubbleView()
                    },
                    declined: declined
                ),
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

        func end() {
            bubbleView.removeFromSuperview()
        }

        // MARK: - Private

        private let viewFactory: ViewFactory
        private let bubbleSize = CGSize(width: 60, height: 60)
        private let bubbleView: BubbleView
        private let presenter: Presenter

        private func createBubbleView() {
            guard let parent = presenter.getInstance()?.view else { return }
            bubbleView.frame = .init(origin: .init(x: parent.frame.maxX, y: parent.frame.maxY), size: bubbleSize)
            parent.addSubview(bubbleView)
            updateBubblePosition()
        }

        private func updateBubblePosition(translation: CGPoint = .zero) {
            var centerX = bubbleView.center.x + translation.x
            var centerY = bubbleView.center.y + translation.y

            defer {
                bubbleView.center = CGPoint(
                    x: centerX,
                    y: centerY
                )
            }

            guard let superview = bubbleView.superview else { return }

            if centerX < bubbleSize.width / 2 {
                centerX = bubbleView.frame.width / 2 + superview.safeAreaInsets.left
            } else if centerX > superview.frame.width - bubbleSize.width / 2 {
                centerX = superview.frame.width - bubbleView.frame.width / 2 - superview.safeAreaInsets.right
            }

            if centerY < bubbleSize.height / 2 {
                centerY = bubbleView.frame.height / 2 + superview.safeAreaInsets.top
            } else if centerY > superview.frame.height - bubbleSize.height / 2 {
                centerY = superview.frame.height - bubbleView.frame.height / 2 - superview.safeAreaInsets.bottom
            }
        }
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
    static func topViewController(application: UIKitBased.UIApplication) -> Self {
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
