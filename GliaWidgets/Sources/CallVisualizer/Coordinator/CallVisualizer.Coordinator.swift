import Foundation
import UIKit

extension CallVisualizer {
    final class Coordinator {
        init(environment: Environment) {
            self.environment = environment
            self.bubbleView = environment.viewFactory.makeBubbleView()

            environment
                .screenShareHandler
                .status
                .addObserver(self) { [weak self] newStatus, _ in
                    switch newStatus {
                    case .started:
                        self?.createBubbleView()
                    case .stopped:
                        self?.end()
                    }
                }

            bubbleView.tap = { [weak self] in
                guard let self = self else { return }
                self.showEndScreenSharingViewController()
            }
            bubbleView.pan = { [weak self] translation in
                self?.updateBubblePosition(translation: translation)
            }
        }

        func showVisitorCodeViewController(by presentation: Presentation) {
            let coordinator = VisitorCodeCoordinator(
                theme: environment.viewFactory.theme,
                environment: .init(
                    timerProviding: environment.timerProviding,
                    requestVisitorCode: environment.requestVisitorCode
                ),
                presentation: presentation
            )

            coordinator.delegate = { [weak self] event in
                switch event {
                case .closeTap:
                    self?.visitorCodeCoordinator = nil
                }
            }

            /// FlowCoordinator protocol requires start() to return a viewController, but it won't be used in Call Visualizer context.
            /// Instead, it is handled seperately because of its unique nature.
            _ = coordinator.start()

            self.visitorCodeCoordinator = coordinator
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
                    accepted: accepted,
                    declined: declined
                ),
                viewFactory: environment.viewFactory
            )
            environment
                .presenter
                .getInstance()?
                .present(alert, animated: true)
        }

        func showEndScreenSharingViewController() {
            let viewController = buildScreenSharingViewController()
            environment
                .presenter
                .getInstance()?
                .present(viewController, animated: true)
        }

        func end() {
            bubbleView.removeFromSuperview()
        }

        // MARK: - Private

        private let environment: Environment
        private let bubbleSize = CGSize(width: 60, height: 60)
        private let bubbleView: BubbleView
        private lazy var screensharingImageView: UIView = {
            let icon = CallVisualizer.BubbleIcon(
                image: UIImage(
                    named: "screensharing",
                    in: environment.bundleManaging.current(),
                    compatibleWith: .none
                ),
                imageSize: .init(width: 24, height: 24)
            ) { [weak self] icon in
                guard let self = self else { return }
                switch self.environment.viewFactory.theme.minimizedBubble.badge?.backgroundColor {
                case .fill(let color):
                    icon.backgroundColor = color
                case .gradient(let colors):
                    icon.makeGradientBackground(
                        colors: colors
                    )
                case .none:
                    break
                }
                icon.layer.masksToBounds = true
                icon.layer.cornerRadius = min(self.bubbleSize.width, self.bubbleSize.height) / 2
            }

            return icon
        }()
        private var visitorCodeCoordinator: VisitorCodeCoordinator?
        private var screenSharingCoordinator: ScreenSharingCoordinator?

        private func createBubbleView() {
            guard let parent = environment.presenter.getInstance()?.view else { return }
            bubbleView.kind = .view(screensharingImageView)
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

        private func buildScreenSharingViewController(uiConfig: RemoteConfiguration? = nil) -> UIViewController {
            let theme = Theme()
            uiConfig.map { theme.applyRemoteConfiguration($0, assetsBuilder: .standard) }
            let coordinator = ScreenSharingCoordinator(
                environment: .init(
                    theme: theme,
                    screenShareHandler: environment.screenShareHandler
                )
            )

            coordinator.delegate = { [weak self] event in
                switch event {
                case .close:
                    self?.screenSharingCoordinator = nil
                }
            }

            let viewController = coordinator.start()
            self.screenSharingCoordinator = coordinator

            return viewController
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
