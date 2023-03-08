import Foundation
import UIKit

extension CallVisualizer {
    final class Coordinator {
        init(environment: Environment) {
            self.environment = environment
            self.bubbleView = environment.viewFactory.makeBubbleView()

            bubbleView.tap = { [weak self] in
                guard let self = self else { return }
                if self.videoCallCoordinator == nil {
                    self.showEndScreenSharingViewController()
                } else {
                    self.resumeVideoCallViewController()
                }
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

            coordinator.start()

            self.visitorCodeCoordinator = coordinator
        }

        func offerScreenShare(
            from operators: [CoreSdkClient.Operator],
            configuration: ScreenShareOfferAlertConfiguration,
            accepted: @escaping () -> Void,
            declined: @escaping () -> Void
        ) {
            let acceptedHandler = { [weak self] in
                self?.observeScreenSharingHandlerState()
                accepted()
            }
            let alert = AlertViewController(
                kind: .screenShareOffer(
                    configuration.withOperatorName(operators.compactMap { $0.name }.joined()),
                    accepted: acceptedHandler,
                    declined: declined
                ),
                viewFactory: environment.viewFactory
            )
            environment
                .presenter
                .getInstance()?
                .present(alert, animated: true)
        }

        func offerMediaUpgrade(
            from operators: [CoreSdkClient.Operator],
            configuration: SingleMediaUpgradeAlertConfiguration,
            accepted: @escaping () -> Void,
            declined: @escaping () -> Void
        ) {
            let alert = AlertViewController(
                kind: .singleMediaUpgrade(
                    configuration.withOperatorName(operators.compactMap { $0.name }.joined()),
                    accepted: accepted,
                    declined: declined
                ),
                viewFactory: environment.viewFactory)
            environment
                .presenter
                .getInstance()?
                .present(alert, animated: true)
        }

        func handleAcceptedUpgrade() {
            guard videoCallCoordinator == nil else { return }
            showVideoCallViewController()
        }

        func showEndScreenSharingViewController() {
            let viewController = buildScreenSharingViewController()
            environment
                .presenter
                .getInstance()?
                .present(viewController, animated: true)
        }

        func showVideoCallViewController() {
            createOperatorImageBubbleView()
            let viewController = buildVideoCallViewController()
            environment
                .presenter
                .getInstance()?
                .present(viewController, animated: true)
        }

        func resumeVideoCallViewController() {
            if let viewController = videoCallCoordinator?.resume() {
                environment
                    .presenter
                    .getInstance()?
                    .present(viewController, animated: true)
            }
        }

        func end() {
            removeBubbleView()
            videoCallCoordinator?.viewController?.dismiss(animated: true)
            videoCallCoordinator = nil
            stopObservingScreenSharingHandlerState()
            screenSharingCoordinator = nil
        }

        func addVideoStream(stream: CoreSdkClient.VideoStreamable) {
            videoCallCoordinator?.call.updateVideoStream(with: stream)
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
        private var videoCallCoordinator: VideoCallCoodinator?

        private func createScreenShareBubbleView() {
            guard let parent = environment.presenter.getInstance()?.view else { return }
            bubbleView.kind = .view(screensharingImageView)
            bubbleView.frame = .init(origin: .init(x: parent.frame.maxX, y: parent.frame.maxY), size: bubbleSize)
            parent.addSubview(bubbleView)
            updateBubblePosition()
        }

        private func createOperatorImageBubbleView() {
            guard let parent = environment.presenter.getInstance()?.view else { return }
            let imageUrl = environment.engagedOperator()?.picture?.url
            bubbleView.kind = .userImage(url: imageUrl)
            if bubbleView.superview == nil {
                bubbleView.frame = .init(origin: .init(x: parent.frame.maxX, y: parent.frame.maxY), size: bubbleSize)
                parent.addSubview(bubbleView)
                updateBubblePosition()
            }
        }

        private func removeBubbleView() {
            bubbleView.removeFromSuperview()
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
            let coordinator = ScreenSharingCoordinator(
                environment: .init(
                    theme: environment.viewFactory.theme,
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

        private func buildVideoCallViewController(uiConfig: RemoteConfiguration? = nil) -> UIViewController {
            let coordinator = VideoCallCoodinator(
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache,
                    timerProviding: environment.timerProviding,
                    uiApplication: environment.uiApplication,
                    date: environment.date,
                    engagedOperator: environment.engagedOperator,
                    screenShareHandler: environment.screenShareHandler
                ),
                uiConfig: uiConfig,
                call: .init(
                    .video(direction: .twoWay),
                    environment: .init(
                        audioSession: environment.audioSession,
                        uuid: environment.uuid
                    )
                )
            )

            let viewController = coordinator.start()
            self.videoCallCoordinator = coordinator

            coordinator.delegate = { event in
                switch event {
                case .close:
                    viewController.dismiss(animated: true)
                }
            }

            return viewController
        }
    }
}

// MARK: - Private

private extension CallVisualizer.Coordinator {
    func observeScreenSharingHandlerState() {
        self.environment
            .screenShareHandler
            .status
            .addObserver(self) { [weak self] newStatus, _ in
                guard self?.videoCallCoordinator == nil else { return }
                switch newStatus {
                case .started:
                    self?.createScreenShareBubbleView()
                case .stopped:
                    self?.removeBubbleView()
                }
            }
    }

    func stopObservingScreenSharingHandlerState() {
        environment.screenShareHandler.status.removeObserver(self)
        environment.screenShareHandler.stop()
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
