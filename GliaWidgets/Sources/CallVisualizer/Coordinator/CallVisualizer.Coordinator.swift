import Foundation
import UIKit
import Combine

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

            interactorSubscription = environment.interactorPublisher
                .sink { [weak self] newInteractor in
                    self?.activeInteractor = newInteractor
                }
        }

        // MARK: - Private
        private var visitorCodeCoordinator: VisitorCodeCoordinator?
        private var videoCallCoordinator: VideoCallCoordinator?
        private var interactorSubscription: AnyCancellable?
        private(set) var activeInteractor: Interactor?
        private var state: State
        private let bubbleSize = CGSize(width: 60, height: 60)
        private let bubbleView: BubbleView
    }
}

extension CallVisualizer.Coordinator {
    func resume() {
        switch state {
        case .initial:
            return
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
            case .closeTapped:
                self?.visitorCodeCoordinator = nil
                self?.environment.log.prefixed(Self.self).info("Dismiss Visitor Code Dialog")
                self?.environment.openTelemetry.logger.i(.visitorCodeClosed)
            case .engagementAccepted:
                switch coordinator.presentation {
                case let .embedded(_, onEngagementAccepted: callback):
                    callback()
                case .alert:
                    break
                }
            case .closeRequested:
                break
            }
        }

        coordinator.start()
        self.environment.openTelemetry.logger.i(.visitorCodeShown) {
            switch presentation {
            case .embedded:
                $0[.viewType] = .string(OtelViewTypes.embedded.rawValue)
            case .alert:
                $0[.viewType] = .string(OtelViewTypes.dialog.rawValue)
            }
        }
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
            self.showSnackBarMessage(text: Localization.Engagement.IncomingRequest.TimedOut.message)
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
        videoCallCoordinator = nil
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

    func restoreVideoCall() {
        if videoCallCoordinator != nil {
            resumeVideoCallViewController()
        } else {
            showVideoCallViewController()
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
        activeInteractor?.endEngagement { _ in }
        end()
    }

    func closeFlow() {
        if let videoCallCoordinator {
            videoCallCoordinator.viewController?.presentingViewController?.dismiss(animated: true)
            environment.eventHandler(.minimized)
        }
    }

    /// Closes the visitor code view controller with specified event and completion handling.
    ///
    /// This method handles the dismissal of visitor code presentations (both alert and embedded types)
    /// and manages the cleanup of the visitor code coordinator.
    ///
    /// - Parameters:
    ///   - event: The delegate event to trigger. Defaults to `.engagementAccepted`.
    ///            Different events may result in different behaviors:
    ///            - `.engagementAccepted`: Normal acceptance flow
    ///            - `.closeTapped`: User manually closed the alert
    ///            - `.closeRequested`: Programmatic close request (only for alert type)
    ///   - completion: Optional closure called after the visitor code is dismissed.
    ///                 For embedded views with `.closeRequested` event, completion is not called.
    func closeVisitorCode(
        event: CallVisualizer.VisitorCodeCoordinator.DelegateEvent = .engagementAccepted,
        _ completion: (() -> Void)? = nil
    ) {
        visitorCodeCoordinator?.delegate?(event)
        if let visitorCode = visitorCodeCoordinator?.codeViewController {
            // Don't dismiss embedded views when close is requested programmatically
            if event == .closeRequested && visitorCode.props.visitorCodeViewProps.viewType == .embedded {
                return
            }
            visitorCode.dismiss(animated: true, completion: completion)
            visitorCodeCoordinator = nil
            environment.openTelemetry.logger.i(.visitorCodeClosed)
        } else {
            completion?()
        }
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
    func createOperatorImageBubbleView() {
        guard let parent = environment.presenter.getInstance()?.view else { return }
        let imageUrl = environment.engagedOperator()?.picture?.url
        bubbleView.kind = .userImage(url: imageUrl)
        if bubbleView.superview == nil {
            bubbleView.frame = .init(origin: .init(x: parent.frame.maxX, y: parent.frame.maxY), size: bubbleSize)
            parent.addSubview(bubbleView)
            environment.openTelemetry.logger.i(.bubbleShown)
            updateBubblePosition()
        }
    }

    func removeBubbleView() {
        bubbleView.removeFromSuperview()
        environment.openTelemetry.logger.i(.bubbleHidden)
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
        case videoCall
    }
}
