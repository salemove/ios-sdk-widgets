import Foundation
import UIKit

extension CallVisualizer {
    final class Coordinator {
        var environment: Environment

        init(environment: Environment) {
            self.environment = environment
            self.bubbleView = environment.viewFactory.makeBubbleView()
            self.state = .initial
            bubbleView.tap = { [weak self] in
                self?.resume()
            }
            bubbleView.pan = { [weak self] translation in
                self?.updateBubblePosition(translation: translation)
            }
        }

        // MARK: - Private
        private var visitorCodeCoordinator: VisitorCodeCoordinator?
        private var screenSharingCoordinator: ScreenSharingCoordinator?
        private var videoCallCoordinator: VideoCallCoordinator?
        private var state: State
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
    }
}

extension CallVisualizer.Coordinator {
    func resume() {
        switch state {
        case .initial:
            return
        case .screenSharing:
            showEndScreenSharingViewController()
        case .videoCall:
            resumeVideoCallViewController()
        }
        environment.eventHandler(.maximized)
    }

    func showVisitorCodeViewController(by presentation: CallVisualizer.Presentation) {
        let coordinator = CallVisualizer.VisitorCodeCoordinator(
            theme: environment.viewFactory.theme,
            environment: .create(with: environment),
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

    func handleAcceptedUpgrade() {
        guard videoCallCoordinator == nil else { return }
        showVideoCallViewController()
    }

    func handleEngagementRequest(
        request: CoreSdkClient.Request,
        answer: Command<Bool>
    ) {
        guard request.outcome == .timedOut else {
            handleEngagementRequestOutcomeNil(answer: answer)
            return
        }
        handleEngagementRequestOutcomeTimeout(answer: answer)
    }

    func handleEngagementRequestOutcomeTimeout(answer: Command<Bool>) {
        environment.alertManager.dismissCurrentAlert()
        environment.gcd.mainQueue.asyncAfterDeadline(.now() + 0.5) {
            // Will be swapped for localized string in MOB-3894
            self.showSnackBarMessage(text: "Request has timed out")
        }
        answer(false)
    }

    func handleEngagementRequestOutcomeNil(answer: Command<Bool>) {
        fetchSiteConfigurations { [weak self] site in
            let showSnackBarIfNeeded: () -> Void = {
                guard site.mobileObservationEnabled == true else { return }
                guard site.mobileObservationIndicationEnabled == true else { return }
                guard let self else { return }
                self.showSnackBarMessage(text: self.environment.viewFactory.theme.snackBar.text)
            }
            let completion: Command<Bool> = .init { isAccepted in
                if isAccepted {
                    showSnackBarIfNeeded()
                }
                answer(isAccepted)
            }
            self?.closeVisitorCode {
                if site.mobileConfirmDialogEnabled == true {
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
            guard site.mobileObservationEnabled == true else { return }
            guard site.mobileObservationIndicationEnabled == true else { return }
            guard let self else { return }
            self.showSnackBarMessage(text: self.environment.viewFactory.theme.snackBar.text)
        }
    }
}

// MARK: - Video screen

extension CallVisualizer.Coordinator {
    func showVideoCallViewController() {
        state = .videoCall
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
            environment: .create(with: environment),
            theme: environment.viewFactory.theme,
            call: .init(
                .video(direction: .twoWay),
                environment: .create(with: environment)
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
        environment.interactorProviding?.endEngagement { _ in }
        end()
    }

    func closeFlow() {
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
    func observeScreenSharingHandlerState() {
        self.environment
            .screenShareHandler
            .status()
            .addObserver(self) { [weak self] newStatus, _ in
                guard self?.videoCallCoordinator == nil else {
                    self?.state = .videoCall
                    return
                }
                switch newStatus {
                case .started:
                    self?.createScreenShareBubbleView()
                    self?.state = .screenSharing
                case .stopped:
                    self?.screenSharingCoordinator?.viewController?.dismiss(animated: true)
                    self?.screenSharingCoordinator = nil
                    self?.removeBubbleView()
                    self?.state = .initial
                }
            }
    }

    private func stopObservingScreenSharingHandlerState() {
        environment.screenShareHandler.status().removeObserver(self)
        environment.screenShareHandler.stop(nil)
    }

    private func buildScreenSharingViewController(uiConfig: RemoteConfiguration? = nil) -> UIViewController {
        let coordinator = CallVisualizer.ScreenSharingCoordinator(
            environment: .create(with: environment)
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
            guard let self else { return }
            switch result {
            case let .success(site):
                completion(site)
            case let .failure(error):
                guard let viewController = environment.presenter.getInstance() else { return }
                self.environment.alertManager.present(
                    in: .root(viewController),
                    as: .error(
                        error: error,
                        dismissed: { [weak self] in
                            self?.declineEngagement()
                        }
                    )
                )
            }
        }
    }
}

// MARK: - Alert
private extension CallVisualizer.Coordinator {
    func showConfirmationAlert(_ answer: Command<Bool>) {
        guard let viewController = environment.presenter.getInstance() else { return }
        environment.alertManager.present(
            in: .root(viewController),
            as: .liveObservationConfirmation(
                link: { [weak self] link in
                    self?.presentSafariViewController(for: link)
                },
                accepted: {
                    answer(true)
                },
                declined: { [weak self] in
                    answer(false)
                    self?.declineEngagement()
                }
            )
        )
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
    func showSnackBarMessage(text: String) {
        environment.snackBar.showSnackBarMessage(
            text: text,
            style: environment.viewFactory.theme.snackBar,
            topMostViewController: topMostViewController,
            timerProviding: environment.timerProviding,
            gcd: environment.gcd,
            notificationCenter: environment.notificationCenter
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

// MARK: - Objects

extension CallVisualizer.Coordinator {
    enum State {
        case initial
        case screenSharing
        case videoCall
    }
}
