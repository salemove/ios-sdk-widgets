import UIKit
import Foundation

extension EngagementCoordinator {
    /// `EngagementLaunching` is used to start one of two possible flows:
    /// - `direct` case is used to start regular engagement flow with single `EngagementKind`. 
    /// In this case `EngagementCoordinator` starts regular engagement.
    /// - `indirect` case is used to temporarily save initial `EngagementKind` and replace it with necessary kind.
    /// Use case is if there is pending secure conversation, but requested `EngagementKind` is
    /// one of `[.chat, . audioCall, .videoCall]`, then `EngagementCoordinator` opens
    /// ChatTranscript screen and shows Leave Engagement Dialog. Then if user presses "Leave" button,
    /// `EngagementCoordinator` replaces current screen with the one corresponding to initial `EngagementKind`.
    enum EngagementLaunching: Equatable {
        case direct(kind: EngagementKind)
        case indirect(kind: EngagementKind, initialKind: EngagementKind)

        var currentKind: EngagementKind {
            switch self {
            case let .direct(engagementKind), let .indirect(engagementKind, _):
                return engagementKind
            }
        }

        var initialKind: EngagementKind {
            switch self {
            case let .direct(engagementKind), let .indirect(_, engagementKind):
                return engagementKind
            }
        }
    }
}

class EngagementCoordinator: SubFlowCoordinator, FlowCoordinator {
    var delegate: ((DelegateEvent) -> Void)?

    var engagementLaunching: EngagementLaunching {
        didSet {
            delegate?(.engagementChanged(engagementLaunching.currentKind))
        }
    }

    var gliaViewController: GliaViewController?
    let interactor: Interactor
    let viewFactory: ViewFactory
    private(set) weak var sceneProvider: SceneProvider?
    private var engagement: Engagement = .none
    private let chatCall = ObservableValue<Call?>(with: nil)
    private let unreadMessages = ObservableValue<Int>(with: 0)
    private let isWindowVisible = ObservableValue<Bool>(with: false)
    private let screenShareHandler: ScreenShareHandler

    private let navigationController = NavigationController()
    let navigationPresenter: NavigationPresenter
    let gliaPresenter: GliaPresenter
    private let kBubbleViewSize: CGFloat = 60.0
    let features: Features
    private let environment: Environment

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementLaunching: EngagementLaunching,
        screenShareHandler: ScreenShareHandler,
        features: Features,
        environment: Environment
    ) {
        self.interactor = interactor
        self.viewFactory = viewFactory
        self.sceneProvider = sceneProvider
        self.engagementLaunching = engagementLaunching
        self.gliaPresenter = GliaPresenter(
            environment: .create(
                with: environment,
                sceneProvider: sceneProvider
            )
        )
        self.navigationPresenter = NavigationPresenter(with: navigationController)
        self.screenShareHandler = screenShareHandler
        self.features = features
        self.environment = environment
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
    }

    func start() {
        start(maximize: true)
    }

    func start(maximize: Bool) {
        setupEngagementController(
            skipTransferredSCHandling: false,
            replaceExistingEnqueueing: false
        )

        let bubbleView = viewFactory.makeBubbleView()
        unreadMessages.addObserver(self) { unreadCount, _ in
            bubbleView.setBadge(itemCount: unreadCount)
        }

        gliaViewController = makeGliaView(
            bubbleView: bubbleView,
            features: features
        )
        gliaViewController?.insertChild(navigationController)
        if maximize {
            delegateEvent(.maximized)
        }
        delegate?(.started)
    }

    func setupEngagementController(
        skipTransferredSCHandling: Bool,
        animated: Bool = false,
        replaceExistingEnqueueing: Bool
    ) {
        let engagementKind = engagementLaunching.currentKind
        switch engagementKind {
        case .none:
            break
        case .chat:
            let chatViewController = startChat(
                withAction: .startEngagement,
                showsCallBubble: false,
                skipTransferredSCHandling: skipTransferredSCHandling,
                replaceExistingEnqueueing: replaceExistingEnqueueing
            )
            engagement = .chat(chatViewController)
            navigationPresenter.setViewControllers(
                [chatViewController],
                animated: animated
            )
        case .audioCall, .videoCall:
            let kind: CallKind = engagementKind == .audioCall
                ? .audio
                : .video(direction: .twoWay)

            let mediaType: CoreSdkClient.MediaType = engagementKind == .audioCall
                ? .audio
                : .video
            let call = Call(
                kind,
                environment: .create(with: environment)
            )
            call.kind.addObserver(self) { [weak self] _, _ in
                self?.engagementLaunching = .direct(kind: EngagementKind(with: call.kind.value))
            }
            let callViewController = startCall(
                call,
                withAction: .engagement(mediaType: mediaType),
                replaceExistingEnqueueing: replaceExistingEnqueueing
            )
            interactor.state = .enqueueing(engagementKind)
            let chatViewController = startChat(
                withAction: .none,
                showsCallBubble: true,
                skipTransferredSCHandling: skipTransferredSCHandling,
                replaceExistingEnqueueing: replaceExistingEnqueueing
            )

            engagement = .call(
                callViewController,
                chatViewController,
                .none,
                call
            )

            navigationPresenter.setViewControllers(
                [callViewController],
                animated: animated
            )
        case .messaging(let messagingInitialScreen):
            let secureConversationsWelcomeViewController = startSecureConversations(
                using: messagingInitialScreen,
                requestedEngagementKind: engagementLaunching.initialKind
            )
            engagement = .secureConversations(secureConversationsWelcomeViewController)
            navigationPresenter.setViewControllers(
                [secureConversationsWelcomeViewController],
                animated: animated
            )
        }
    }

    deinit {
        print("\(Self.self) is deallocated.")
    }
}

extension EngagementCoordinator {
    func end(
        surveyPresentation: SecureConversations.Coordinator.DelegateEvent.SurveyPresentation
    ) {
        switch engagement {
        case let .call(_, _, _, call):
            call.kind.removeObserver(self)
            chatCall.value?.kind.removeObserver(self)
            chatCall.value = nil
        default:
            break
        }

        let engagementEnded = interactor.state.isEnded

        let dismissGliaViewController: () -> Void = { [weak self] in
            self?.dismissGliaViewController(animated: true) { [weak self] in
                self?.delegateEvent(.minimized)
                self?.engagement = .none
                self?.navigationPresenter.setViewControllers([], animated: false)
                self?.removeAllCoordinators()
                self?.engagementLaunching = .direct(kind: .none)
                // If engagement was ended then pass `ended` event. This
                // initiates sending `ended` event to integrators.
                // Otherwise, pass `closed` meaning that Glia screen was closed
                // without having an engagement. This does not send `ended` event to integrators.
                if engagementEnded {
                    self?.delegate?(.ended)
                } else {
                    self?.delegate?(.closed)
                }
            }
        }

        guard let engagement = interactor.endedEngagement,
                engagement.actionOnEnd == .showSurvey,
                surveyPresentation == .presentSurvey else {
            dismissGliaViewController()
            return
        }

        func handleSurveyResult(
            _ result: Result<CoreSdkClient.Survey?, CoreSdkClient.GliaCoreError>,
            in coordinator: EngagementCoordinator
        ) {
            switch result {
            case let .success(.some(survey)):
                environment.log.prefixed(Self.self).info("Survey loaded")
                presentSurvey(
                    engagementId: engagement.id,
                    survey: survey,
                    dismissGliaViewController: dismissGliaViewController
                )
            case .success(.none):
                dismissGliaViewController()
            case let .failure(error):
                presentSurveyError(error, dismissGliaViewController: dismissGliaViewController)
            }
        }

        engagement.getSurvey { [weak self] surveyResult in
            guard let self else { return }
            handleSurveyResult(
                surveyResult,
                in: self
            )
        }
    }

    func presentSurveyError(
        _ error: Error,
        dismissGliaViewController: @escaping () -> Void
    ) {
        environment.alertManager.present(
            in: .global,
            as: .error(
                error: error,
                dismissed: dismissGliaViewController
            )
        )
    }

    private func presentSurvey(
        engagementId: String,
        survey: CoreSdkClient.Survey,
        dismissGliaViewController: @escaping () -> Void?
    ) {
        environment.log.prefixed(Self.self).info("Create Survey screen")
        let viewController = Survey.ViewController(
            viewFactory: self.viewFactory,
            environment: .create(with: environment)
        )
        viewController.props = .live(
            sdkSurvey: survey,
            engagementId: engagementId,
            submitSurveyAnswer: { [environment] in
                environment.log.prefixed(Self.self).info("Submit survey answers")
                environment.submitSurveyAnswer($0, $1, $2, $3)
            },
            cancel: { [weak self] in
                guard let self else { return }
                viewController.dismiss(animated: true) {
                    self.interactor.cleanup()
                    dismissGliaViewController()
                }
            },
            endEditing: { viewController.view.endEditing(true) },
            updateProps: { viewController.props = $0 },
            onError: { [weak self] error in
                guard let self else { return }
                self.interactor.cleanup()
                environment.alertManager.present(
                    in: .root(viewController),
                    as: .error(error: error)
                )
            },
            completion: { [weak self] in
                guard let self else { return }
                viewController.dismiss(animated: true) {
                    self.interactor.cleanup()
                    dismissGliaViewController()
                }
            }
        )
        self.gliaViewController?.removeBubbleWindow()
        self.gliaPresenter.present(viewController, animated: true)
    }

    private func startChat(
        withAction startAction: ChatViewModel.StartAction,
        showsCallBubble: Bool,
        skipTransferredSCHandling: Bool,
        replaceExistingEnqueueing: Bool
    ) -> ChatViewController {
        let coordinator = ChatCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            navigationPresenter: navigationPresenter,
            call: chatCall,
            unreadMessages: unreadMessages,
            showsCallBubble: showsCallBubble,
            screenShareHandler: screenShareHandler,
            isWindowVisible: isWindowVisible,
            startAction: startAction,
            environment: .create(
                with: environment,
                interactor: interactor,
                shouldShowLeaveSecureConversationDialog: { [weak self] source in
                    guard let self else { return false }
                    switch source {
                    case .transcriptOpened:
                        return false
                    case .entryWidgetTopBanner:
                        return environment.hasPendingInteraction()
                    }
                },
                leaveCurrentSecureConversation: .nop,
                switchToEngagement: .init { [weak self] kind in
                    self?.switchToEngagementKind(
                        kind,
                        // Replace existing queue ticket here too.
                        replaceExistingEnqueueing: true
                    )
                }
            ),
            startWithSecureTranscriptFlow: false,
            skipTransferredSCHandling: skipTransferredSCHandling
        )
        coordinator.delegate = { [weak self] event in
            self?.handleChatCoordinatorEvent(event: event)
        }
        pushCoordinator(coordinator)

        return coordinator.start(replaceExistingEnqueueing: replaceExistingEnqueueing)
    }

    private func handleChatCoordinatorEvent(event: ChatCoordinator.DelegateEvent) {
        switch event {
        case .back:
            switch engagement {
            case .chat:
                if case .none = interactor.state {
                    popCoordinator()
                    end(surveyPresentation: .presentSurvey)
                } else {
                    gliaViewController?.minimize(animated: true)
                }
            case .call(let callViewController, _, let upgradedFrom, _):
                if upgradedFrom == .chat {
                    gliaViewController?.minimize(animated: true)
                } else {
                    navigationPresenter.pop(to: callViewController, animated: true)
                }
            default:
                popCoordinator()
                end(surveyPresentation: .presentSurvey)
            }
        case let .openLink(link):
            presentSafariViewController(for: link)
        case .engaged(let operatorImageUrl):
            gliaViewController?.bubbleKind = .userImage(url: operatorImageUrl)
        case .mediaUpgradeAccepted(let offer, let answer):
            chatMediaUpgradeAccepted(offer: offer, answer: answer)
        case .secureTranscriptUpgradedToLiveChat(let chatViewController):
            upgradeSecureTranscriptToChat(chatViewController: chatViewController)
        case .call:
            switch engagement {
            case .call(let callViewController, _, let upgradedFrom, _):
                switch upgradedFrom {
                case .none:
                    navigationController.popToViewController(callViewController, animated: true)
                case .chat:
                    navigationPresenter.push(callViewController, animated: true)
                }
            default:
                break
            }
        case .finished:
            popCoordinator()
            self.end(surveyPresentation: .presentSurvey)
        case .minimize:
            minimize()
        }
    }

    private func startCall(
        _ call: Call,
        withAction startAction: CallViewModel.StartAction,
        replaceExistingEnqueueing: Bool
    ) -> CallViewController {
        let coordinator = CallCoordinator(
            interactor: interactor,
            viewFactory: viewFactory,
            navigationPresenter: navigationPresenter,
            call: call,
            unreadMessages: unreadMessages,
            screenShareHandler: screenShareHandler,
            startAction: startAction,
            environment: .create(with: environment)
        )
        coordinator.delegate = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .back:
                switch self.engagement {
                case .call(_, let chatViewController, let upgradedFrom, _):
                    if upgradedFrom == .chat {
                        self.navigationPresenter.pop(to: chatViewController, animated: true)
                    } else {
                        self.gliaViewController?.minimize(animated: true)
                    }
                default:
                    break
                }
            case let .openLink(link):
                self.presentSafariViewController(for: link)
            case .engaged(let operatorImageUrl):
                self.gliaViewController?.bubbleKind = .userImage(url: operatorImageUrl)
            case .chat:
                switch self.engagement {
                case .call(_, let chatViewController, let upgradedFrom, _):
                    if upgradedFrom == .chat {
                        self.navigationPresenter.pop(to: chatViewController, animated: true)
                    } else {
                        self.navigationPresenter.push(chatViewController, animated: true)
                    }
                default:
                    break
                }
            case .minimize:
                self.gliaViewController?.minimize(animated: true)
            case .finished:
                self.popCoordinator()
                self.end(surveyPresentation: .presentSurvey)
            case .visitorOnHoldUpdated(let isOnHold):
                self.gliaViewController?.setVisitorHoldState(isOnHold: isOnHold)
            }
        }
        pushCoordinator(coordinator)

        return coordinator.start(replaceExistingEnqueueing: replaceExistingEnqueueing)
    }

    private func makeGliaView(
        bubbleView: BubbleView,
        features: Features
    ) -> GliaViewController {
        let animate: (
            _ animated: Bool,
            _ animations: @escaping () -> Void,
            _ completion: @escaping (
                Bool
            ) -> Void
        ) -> Void = { animated, animations, completion in
            UIView.animate(
                withDuration: animated ? 0.4 : 0.0,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.7,
                options: .curveEaseInOut,
                animations: animations,
                completion: completion
            )
        }

        if let sceneProvider = sceneProvider {
            return GliaViewController(
                bubbleView: bubbleView,
                delegate: { [weak self] event in
                    self?.delegateEvent(event)
                },
                features: features,
                environment: .create(
                    with: environment,
                    animate: animate
                )
            )
        } else {
            return GliaViewController(
                bubbleView: bubbleView,
                delegate: { [weak self] event in
                    self?.delegateEvent(event)
                },
                features: features,
                environment: .create(
                    with: environment,
                    animate: animate
                )
            )
        }
    }

    private func startSecureConversations(
        using messagingInitialScreen: SecureConversations.InitialScreen,
        requestedEngagementKind: EngagementKind
    ) -> UIViewController {
        // TODO: Cover `replaceExistingEnqueueing` with unit tests (MOB-4047)
        let leaveCurrentSecureConversation = Command<Bool> { [weak self] accepted in
            if accepted {
                self?.switchToEngagementKind(
                    requestedEngagementKind,
                    // We need to replace existing queue ticket
                    // here when switching to engagement from SC.
                    replaceExistingEnqueueing: true
                )
            } else {
                self?.engagementLaunching = .direct(kind: .messaging(.chatTranscript))
            }
        }
        let coordinator = SecureConversations.Coordinator(
            messagingInitialScreen: messagingInitialScreen,
            viewFactory: viewFactory,
            navigationPresenter: navigationPresenter,
            environment: .create(
                with: environment,
                queueIds: interactor.queueIds ?? [],
                viewFactory: viewFactory,
                chatCall: chatCall,
                unreadMessages: unreadMessages,
                showCallBubble: false,
                screenShareHandler: screenShareHandler,
                isWindowVisible: isWindowVisible,
                interactor: interactor,
                shouldShowLeaveSecureConversationDialog: { [weak self] source in
                    guard let self else { return false }
                    switch source {
                    case .transcriptOpened:
                        guard case .indirect = engagementLaunching else { return false }
                        return true
                    case .entryWidgetTopBanner:
                        return environment.hasPendingInteraction()
                    }
                },
                leaveCurrentSecureConversation: leaveCurrentSecureConversation,
                switchToEngagement: .init { [weak self] kind in
                    self?.switchToEngagementKind(
                        kind,
                        // Replace existing queue ticket here too.
                        replaceExistingEnqueueing: true
                    )
                }
            )
        )

        coordinator.delegate = { [weak self] event in
            self?.handleSecureConversationsCoordinatorEvent(event)
        }

        pushCoordinator(coordinator)

        return coordinator.start()
    }

    private func handleSecureConversationsCoordinatorEvent(_ event: SecureConversations.Coordinator.DelegateEvent) {
        switch event {
        case .closeTapped(let surveyPresentation):
            self.popCoordinator()
            self.end(surveyPresentation: surveyPresentation)
        case .backTapped:
            self.gliaViewController?.minimize(animated: true)
        case let .chat(chatEvent):
            self.handleChatCoordinatorEvent(event: chatEvent)
        }
    }

    private func switchToEngagementKind(
        _ kind: EngagementKind,
        replaceExistingEnqueueing: Bool
    ) {
        engagementLaunching = .direct(kind: kind)
        setupEngagementController(
            skipTransferredSCHandling: true,
            animated: true,
            replaceExistingEnqueueing: replaceExistingEnqueueing
        )
    }
}

extension EngagementCoordinator {
    private func presentGliaViewController(animated: Bool, completion: (() -> Void)? = nil) {
        guard let gliaViewController = gliaViewController else { return }
        gliaPresenter.present(gliaViewController, animated: animated) { [weak self] in
            self?.isWindowVisible.value = true
            completion?()
        }
    }

    private func dismissGliaViewController(animated: Bool, completion: (() -> Void)? = nil) {
        guard let gliaViewController = gliaViewController else { return }
        gliaPresenter.dismiss(gliaViewController, animated: animated) { [weak self] in
            self?.isWindowVisible.value = false
            completion?()
        }
    }
}

extension EngagementCoordinator {
    private func chatMediaUpgradeAccepted(
        offer: CoreSdkClient.MediaUpgradeOffer,
        answer: @escaping CoreSdkClient.AnswerWithSuccessBlock
    ) {
        switch engagement {
        case .chat(let chatViewController):
            guard let kind = CallKind(with: offer) else { return }
            let call = Call(
                kind,
                environment: .create(with: environment)
            )
            call.kind.addObserver(self) { [weak self] _, _ in
                self?.engagementLaunching = .direct(kind: EngagementKind(with: call.kind.value))
            }
            let callViewController = startCall(
                call,
                withAction: .call(
                    offer: offer,
                    answer: { [environment] accepted, successHandler in
                            environment.log.prefixed(Self.self).info(
                                accepted ? "Media upgrade request accepted by visitor"
                                         : "Media upgrade request declined by visitor"
                            )

                        answer(accepted, successHandler)
                    }
                ),
                replaceExistingEnqueueing: false
            )
            engagement = .call(
                callViewController,
                chatViewController,
                .chat,
                call
            )
            chatCall.value = call
            navigationPresenter.push(callViewController)

        case .call(let callViewController, let chatViewController, _, let call):
            call.upgrade(to: offer)
            engagement = .call(
                callViewController,
                chatViewController,
                .none,
                call
            )
            navigationPresenter.setViewControllers(
                [callViewController],
                animated: true
            )
            answer(true, nil)
            environment.log.prefixed(Self.self).info(
                "Media upgrade request accepted by visitor"
            )

        case .secureConversations, .none:
            break
        }
    }

    private func upgradeSecureTranscriptToChat(chatViewController: ChatViewController) {
        engagement = .chat(chatViewController)
    }
}

extension EngagementCoordinator {
    func presentSafariViewController(for link: WebViewController.Link) {
        let openBrowser = Command<URL> { [weak self] url in
            guard let self,
                  self.environment.uiApplication.canOpenURL(url)
            else { return }
            self.environment.uiApplication.open(url)
        }
        let viewController = WebViewController()
        viewController.modalPresentationStyle = .fullScreen

        let close = Cmd { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        let theme = viewFactory.theme
        let headerProps = Header.Props(
            title: link.title,
            effect: .none,
            endButton: nil,
            backButton: nil,
            closeButton: .init(tap: close, style: theme.webView.header.closeButton),
            endScreenshareButton: nil,
            style: theme.webView.header
        )

        let props: WebViewController.Props = .init(
            link: link.url,
            header: headerProps,
            externalOpen: openBrowser
        )
        viewController.props = props
        gliaPresenter.present(viewController, animated: true)
    }
}

extension EngagementCoordinator {
    func delegateEvent(_ event: GliaViewControllerEvent) {
        switch event {
        case .minimized:
            dismissGliaViewController(animated: true) { [weak self] in
                self?.isWindowVisible.value = false
                self?.delegate?(.minimized)
            }
        case .maximized:
            presentGliaViewController(animated: true) { [weak self] in
                self?.isWindowVisible.value = true
                self?.delegate?(.maximized)
            }
        }
    }
}

extension EngagementCoordinator {
    func minimize() {
        gliaViewController?.minimize(animated: true)
    }

    func maximize() {
        gliaViewController?.maximize(animated: true)
    }
}

extension EngagementKind {
    init(with kind: CallKind) {
        switch kind {
        case .audio:
            self = .audioCall
        case .video:
            self = .videoCall
        }
    }
}

extension EngagementCoordinator {
    enum DelegateEvent: Equatable {
        case started
        case engagementChanged(EngagementKind)
        // Glia screen is closed after once an engagement is ended
        case ended
        // Glia screen is closed without having an engagement
        case closed
        case minimized
        case maximized
    }

    private enum Engagement {
        case none
        case chat(ChatViewController)
        case call(CallViewController, ChatViewController, UpgradedFrom, Call)
        case secureConversations(UIViewController)
    }

    private enum UpgradedFrom {
        case none
        case chat
    }
}
