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
                environment.eventHandler(.maximized)
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
                case .engagementAccepted:
                    switch coordinator.presentation {
                    case let .embedded(_, onEngagementAccepted: callback):
                        callback()
                    case .alert:
                        break
                    }
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
                self?.mediaUpgradeViewController = nil
                self?.observeScreenSharingHandlerState()
                accepted()
            }
            let declinedHandler = { [weak self] in
                self?.mediaUpgradeViewController = nil
                declined()
            }

            let alert = AlertViewController(
                kind: .screenShareOffer(
                    configuration.withOperatorName(operators.compactMap { $0.name }.joined()),
                    accepted: acceptedHandler,
                    declined: declinedHandler
                ),
                viewFactory: environment.viewFactory
            )
            mediaUpgradeViewController = alert
            presentAlert(alert)
        }

        func offerMediaUpgrade(
            from operators: [CoreSdkClient.Operator],
            configuration: SingleMediaUpgradeAlertConfiguration,
            accepted: @escaping () -> Void,
            declined: @escaping () -> Void
        ) {
            func actionWrapper(_ action: @escaping () -> Void) -> () -> Void {
                return { [weak self] in
                    self?.mediaUpgradeViewController = nil
                    action()
                }
            }

            let alert = AlertViewController(
                kind: .singleMediaUpgrade(
                    configuration.withOperatorName(operators.compactMap { $0.name }.joined()),
                    accepted: actionWrapper(accepted),
                    declined: actionWrapper(declined)
                ),
                viewFactory: environment.viewFactory
            )
            mediaUpgradeViewController = alert
            presentAlert(alert)
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

        func resumeVideoCallViewController() {
            if let viewController = videoCallCoordinator?.resume() {
                environment
                    .presenter
                    .getInstance()?
                    .present(viewController, animated: true)
            }
        }

        func handleEngagementRequestAccepted() {
            visitorCodeCoordinator?.delegate?(.engagementAccepted)
            visitorCodeCoordinator?.codeViewController?.dismiss(animated: true)
            visitorCodeCoordinator = nil
        }

        func end() {
            removeBubbleView()
            closeFlow()
            stopObservingScreenSharingHandlerState()
            videoCallCoordinator = nil
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
        private var videoCallCoordinator: VideoCallCoordinator?
        private var mediaUpgradeViewController: AlertViewController?

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

        private func buildVideoCallViewController() -> UIViewController {
            let coordinator = VideoCallCoordinator(
                environment: .init(
                    data: environment.data,
                    uuid: environment.uuid,
                    gcd: environment.gcd,
                    imageViewCache: environment.imageViewCache,
                    timerProviding: environment.timerProviding,
                    uiApplication: environment.uiApplication,
                    uiScreen: environment.uiScreen,
                    uiDevice: environment.uiDevice,
                    notificationCenter: environment.notificationCenter,
                    date: environment.date,
                    engagedOperator: environment.engagedOperator,
                    screenShareHandler: environment.screenShareHandler
                ),
                theme: environment.viewFactory.theme,
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

            coordinator.delegate = { [weak self] event in
                switch event {
                case .close:
                    self?.closeFlow()
                    self?.screenSharingCoordinator = nil
                }
            }

            return viewController
        }

        func showVideoCallViewController() {
            createOperatorImageBubbleView()
            let viewController = buildVideoCallViewController()
            environment
                .presenter
                .getInstance()?
                .present(viewController, animated: true)
            environment.eventHandler(.maximized)
        }
    }
}

// MARK: - Private

private extension CallVisualizer.Coordinator {
    func observeScreenSharingHandlerState() {
        self.environment
            .screenShareHandler
            .status()
            .addObserver(self) { [weak self] newStatus, _ in
                guard self?.videoCallCoordinator == nil else { return }
                switch newStatus {
                case .started:
                    self?.createScreenShareBubbleView()
                case .stopped:
                    self?.screenSharingCoordinator?.viewController?.dismiss(animated: true)
                    self?.screenSharingCoordinator = nil
                    self?.removeBubbleView()
                }
            }
    }

    func stopObservingScreenSharingHandlerState() {
        environment.screenShareHandler.status().removeObserver(self)
        environment.screenShareHandler.stop(nil)
    }

    func closeFlow() {
        // If media upgrade AlertViewController is presented it need to be dismissed.
        // Possible cases:
        // - Presented over integrators screen (or Testing app main screen)
        // - Presented over Glia Call Visualizer screens
        mediaUpgradeViewController?.dismiss(animated: true)
        mediaUpgradeViewController = nil

        // Presented flow can consist of:
        // - Only screen sharing screen is presented from Root (Main) controller.
        // - Only Video call screen is presented from Root (Main) controller.
        // - Video call screen is presented over Screen sharing screen,
        // which is presented from Root (Main) controller.
        //
        // To dismiss all presented controllers just need to call `dismiss` from Root (Main) controller.
        // If Screen sharing screen is exist, no matter whether Video call screen is presented over it,
        // screenSharingCoordinator?.viewController.presentingViewController is Root (Main) controller,
        // otherwise videoCallCoordinator?.viewController?.presentingViewController is Root (Main) controller.
        switch (screenSharingCoordinator, videoCallCoordinator) {
        case (.some(let screenSharing), _):
            screenSharing.viewController?.presentingViewController?.dismiss(animated: true)
            environment.eventHandler(.minimized)
        case (.none, .some(let videoCall)):
            videoCall.viewController?.presentingViewController?.dismiss(animated: true)
            environment.eventHandler(.minimized)
        case (.none, .none):
            break
        }
    }

    func createScreenShareBubbleView() {
        guard let parent = environment.presenter.getInstance()?.view else { return }
        bubbleView.kind = .view(screensharingImageView)
        bubbleView.frame = .init(origin: .init(x: parent.frame.maxX, y: parent.frame.maxY), size: bubbleSize)
        parent.addSubview(bubbleView)
        updateBubblePosition()
    }

    func createOperatorImageBubbleView() {
        guard let parent = environment.presenter.getInstance()?.view else { return }
        let imageUrl = environment.engagedOperator()?.picture?.url
        bubbleView.kind = .userImage(url: imageUrl)
        if bubbleView.superview == nil {
            bubbleView.frame = .init(origin: .init(x: parent.frame.maxX, y: parent.frame.maxY), size: bubbleSize)
            parent.addSubview(bubbleView)
            updateBubblePosition()
        }
    }

    func removeBubbleView() {
        bubbleView.removeFromSuperview()
    }

    func updateBubblePosition(translation: CGPoint = .zero) {
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

    func presentAlert(_ alert: AlertViewController) {
        let topController = environment.presenter.getInstance()

        // If replaceable is not nil, that means some AlertViewController is presented,
        // and we need to decide whether to replace presented alert.
        // Otherwise, just present requested alert.
        guard let replaceable = topController as? Replaceable else {
            topController?.present(alert, animated: true)
            return
        }
        let presenting = replaceable.presentingViewController
        guard replaceable.isReplaceable(with: alert) else { return }
        replaceable.dismiss(animated: true) {
            presenting?.present(alert, animated: true)
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
            if var topController = application.windows().first(where: { $0.isKeyWindow })?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }
            return nil
        }
    }
}
