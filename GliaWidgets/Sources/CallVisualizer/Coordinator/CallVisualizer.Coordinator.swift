import Foundation
import UIKit

extension CallVisualizer {
    final class Coordinator {
        private let snackBar = SnackBar()

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
                    self?.environment.log.prefixed(Self.self).info("Dismiss Visitor Code Dialog")
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
                self?.alertViewController = nil
                self?.observeScreenSharingHandlerState()
                accepted()
            }
            let declinedHandler = { [weak self] in
                self?.alertViewController = nil
                declined()
            }

            environment.log.prefixed(Self.self).info("Show Start Screen Sharing Dialog")

            let alert = AlertViewController(
                kind: .screenShareOffer(
                    configuration.withOperatorName(operators.compactMap { $0.name }.joined()),
                    accepted: acceptedHandler,
                    declined: declinedHandler
                ),
                viewFactory: environment.viewFactory
            )
            alertViewController = alert
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
                    self?.alertViewController = nil
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
            alertViewController = alert
            presentAlert(alert)
        }

        func handleAcceptedUpgrade() {
            guard videoCallCoordinator == nil else { return }
            showVideoCallViewController()
        }

        func handleEngagementRequestAccepted(_ answer: Command<Bool>) {
            fetchSiteConfigurations { [weak self] site in
                let showSnackBarIfNeeded: () -> Void = {
                    if site.observationIndication {
                        self?.showSnackBarMessage()
                    }
                }
                let completion: Command<Bool> = .init { isAccepted in
                    if isAccepted {
                        showSnackBarIfNeeded()
                    }
                    answer(isAccepted)
                }
                self?.closeVisitorCode {
                    if site.mobileConfirmDialog {
                        self?.showConfirmationAlert(completion)
                    } else {
                        showSnackBarIfNeeded()
                        answer(true)
                    }
                }
            }
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

        func showSnackBarIfNeeded() {
            fetchSiteConfigurations { [weak self] site in
                if site.observationIndication {
                    self?.showSnackBarMessage()
                }
            }
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
        private var alertViewController: AlertViewController?
    }
}

// MARK: - Video screen

extension CallVisualizer.Coordinator {
    func showVideoCallViewController() {
        createOperatorImageBubbleView()
        let viewController = buildVideoCallViewController()
        environment
            .presenter
            .getInstance()?
            .present(viewController, animated: true)
        environment.eventHandler(.maximized)
    }

    private func buildVideoCallViewController() -> UIViewController {
        let coordinator = CallVisualizer.VideoCallCoordinator(
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
                screenShareHandler: environment.screenShareHandler,
                proximityManager: environment.proximityManager
            ),
            theme: environment.viewFactory.theme,
            call: .init(
                .video(direction: .twoWay),
                environment: .init(
                    theme: environment.viewFactory.theme,
                    screenShareHandler: environment.screenShareHandler,
                    orientationManager: environment.orientationManager,
                    log: environment.log,
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

    func resumeVideoCallViewController() {
        if let viewController = videoCallCoordinator?.resume() {
            environment
                .presenter
                .getInstance()?
                .present(viewController, animated: true)
        }
    }
}

// MARK: - Ending engagement

extension CallVisualizer.Coordinator {
    func declineEngagement() {
        environment.interactorProviding?.endEngagement(
            success: {},
            failure: { _ in }
        )
        end()
    }

    func closeFlow() {
        // If media upgrade AlertViewController is presented it need to be dismissed.
        // Possible cases:
        // - Presented over integrators screen (or Testing app main screen)
        // - Presented over Glia Call Visualizer screens
        alertViewController?.dismiss(animated: true)
        alertViewController = nil

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

    func closeVisitorCode(_ completion: (() -> Void)? = nil) {
        visitorCodeCoordinator?.delegate?(.engagementAccepted)
        if let visitorCode = visitorCodeCoordinator?.codeViewController {
            visitorCode.dismiss(animated: true, completion: completion)
            visitorCodeCoordinator = nil
        } else {
            completion?()
        }
    }
}

// MARK: - Screen sharing

extension CallVisualizer.Coordinator {
    private func observeScreenSharingHandlerState() {
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

    private func stopObservingScreenSharingHandlerState() {
        environment.screenShareHandler.status().removeObserver(self)
        environment.screenShareHandler.stop(nil)
    }

    private func buildScreenSharingViewController(uiConfig: RemoteConfiguration? = nil) -> UIViewController {
        let coordinator = CallVisualizer.ScreenSharingCoordinator(
            environment: .init(
                theme: environment.viewFactory.theme,
                screenShareHandler: environment.screenShareHandler,
                orientationManager: environment.orientationManager
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

    func showEndScreenSharingViewController() {
        let viewController = buildScreenSharingViewController()
        environment
            .presenter
            .getInstance()?
            .present(viewController, animated: true)
    }
}

// MARK: - Site configurations

private extension CallVisualizer.Coordinator {
    func fetchSiteConfigurations(_ completion: @escaping (CoreSdkClient.Site) -> Void) {
        environment.fetchSiteConfigurations { [weak self] result in
            switch result {
            case let .success(site):
                completion(site)
            case .failure:
                self?.showUnexpectedErrorAlert()
            }
        }
    }
}

// MARK: - Alert

private extension CallVisualizer.Coordinator {
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

    func showConfirmationAlert(_ answer: Command<Bool>) {
        let alert = AlertViewController(
            kind: .liveObservationConfirmation(
                environment.viewFactory.theme.alertConfiguration.liveObservationConfirmation,
                link: { [weak self] link in
                    self?.presentSafariViewController(for: link)
                },
                accepted: { [weak self] in
                    answer(true)
                    self?.alertViewController = nil
                },
                declined: { [weak self] in
                    answer(false)
                    self?.alertViewController = nil
                    self?.declineEngagement()
                }
            ),
            viewFactory: environment.viewFactory
        )
        self.alertViewController = alert
        self.presentAlert(alert)
    }

    func showUnexpectedErrorAlert() {
        let config: MessageAlertConfiguration = environment.viewFactory.theme.alertConfiguration.unexpectedError
        let alert = AlertViewController(
            kind: .message(
                config,
                accessibilityIdentifier: nil,
                dismissed: { [weak self] in
                    self?.declineEngagement()
                }
            ),
            viewFactory: environment.viewFactory
        )
        alertViewController = alert
        presentAlert(alert)
    }
}

// MARK: - Bubble

private extension CallVisualizer.Coordinator {
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
}

// MARK: - WebViewController

private extension CallVisualizer.Coordinator {
    func presentSafariViewController(for link: WebViewController.Link) {
        let openBrowser = Command<URL> { [weak self] url in
            guard let self,
                  self.environment.uiApplication.canOpenURL(url)
            else { return }
            self.environment.uiApplication.open(url)
        }
        let close = Cmd { [weak self] in
            self?.environment
                .presenter
                .getInstance()?
                .dismiss(animated: true)
        }
        let theme = environment.viewFactory.theme
        let headerProps = Header.Props(
            title: link.title,
            effect: .none,
            endButton: nil,
            backButton: nil,
            closeButton: .init(tap: close, style: theme.chat.header.closeButton),
            endScreenshareButton: nil,
            style: theme.chat.header
        )

        let props: WebViewController.Props = .init(
            link: link.url,
            header: headerProps,
            externalOpen: openBrowser
        )

        let viewController = WebViewController(props: props)
        viewController.modalPresentationStyle = .fullScreen
        environment
            .presenter
            .getInstance()?
            .present(viewController, animated: true)
    }
}

// MARK: - Live Observation

private extension CallVisualizer.Coordinator {
    func showSnackBarMessage() {
        let style = environment.viewFactory.theme.snackBar
        snackBar.present(
            text: style.text,
            style: style,
            for: topMostViewController,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd
        )
    }

    var topMostViewController: UIViewController {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        guard var presenter = window?.rootViewController else {
            fatalError("Could not find UIViewController to present on")
        }

        while let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }

        return presenter
    }
}
