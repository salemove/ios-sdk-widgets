import UIKit
import Foundation

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
    private let layoutMode: EngagementLayoutMode
    private(set) var panelWindow: EngagementPanelWindow?
    private(set) var splitViewController: EngagementSplitViewController?
    private var bubblePresenter: BubblePresenter?

    private let navigationController = NavigationController()
    let navigationPresenter: NavigationPresenter
    let gliaPresenter: GliaPresenter
    private let kBubbleViewSize: CGFloat = 60.0
    let features: Features
    private let environment: Environment
    private var engagementRestorationState: () -> (EngagementRestorationState)

    init(
        interactor: Interactor,
        viewFactory: ViewFactory,
        sceneProvider: SceneProvider?,
        engagementLaunching: EngagementLaunching,
        features: Features,
        engagementRestorationState: @escaping () -> (EngagementRestorationState),
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
        self.features = features
        self.engagementRestorationState = engagementRestorationState
        self.environment = environment
        self.layoutMode = environment.resolveLayoutMode(
            Self.resolveWindowScene(
                sceneProvider: sceneProvider,
                connectedScenes: environment.uiApplication.connectionScenes()
            )
        )
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
    }

    func start() {
        start(maximize: true)
    }

    func start(maximize: Bool) {
        let bubbleView = viewFactory.makeBubbleView()
        unreadMessages.addObserver(self) { unreadCount, _ in
            bubbleView.setBadge(itemCount: unreadCount)
        }

        // The panel/split surface is created before the engagement content, so
        // that `setupEngagementController` can place the call view controller
        // into `splitViewController` when starting directly into a call.
        switch layoutMode {
        case .fullScreen:
            gliaViewController = makeGliaView(
                bubbleView: bubbleView,
                features: features
            )
            gliaViewController?.insertChild(navigationController)
        case .sidePanel:
            bubblePresenter = makeBubblePresenter(
                bubbleView: bubbleView,
                features: features
            )
            // Alerts the chat raises over itself must dim the panel only, not the
            // whole scene including the host app.
            navigationController.confinesAlertsToOwnBounds = true
            navigationController.definesPresentationContext = true
            navigationController.providesPresentationContextTransitionStyle = true
            let splitViewController = EngagementSplitViewController()
            splitViewController.setPanel(navigationController)
            self.splitViewController = splitViewController
            panelWindow = makePanelWindow(rootViewController: splitViewController)
        }

        setupEngagementController(
            skipTransferredSCHandling: false,
            replaceExistingEnqueueing: false
        )

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
            setupCallEngagementController(
                engagementKind: engagementKind,
                skipTransferredSCHandling: skipTransferredSCHandling,
                animated: animated,
                replaceExistingEnqueueing: replaceExistingEnqueueing
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

    private func setupCallEngagementController(
        engagementKind: EngagementKind,
        skipTransferredSCHandling: Bool,
        animated: Bool,
        replaceExistingEnqueueing: Bool
    ) {
        let kind: CallKind = engagementKind == .audioCall ? .audio : .video(direction: .twoWay)

        let mediaType: CoreSdkClient.MediaType = engagementKind == .audioCall ? .audio : .video
        let call = Call(kind, environment: .create(with: environment))
        call.kind.addObserver(self) { [weak self] _, _ in
            self?.engagementLaunching = .direct(kind: EngagementKind(with: call.kind.value))
        }
        let callViewController = startCall(
            call,
            withAction: .engagement(mediaType: mediaType),
            replaceExistingEnqueueing: replaceExistingEnqueueing
        )

        // Do not set the state back to `enqueueing` if we are already engaged
        // and simply restoring the session. This situation occurs when a user
        // authenticates during an active call, and preventing this state change
        // avoids breaking the UI controls on the Call screen.
        if !(interactor.isEngaged && engagementRestorationState() == .restoring) {
            interactor.state = .enqueueing(engagementKind)
        }

        let chatViewController = startChat(
            withAction: .none,
            // The in-chat call bubble is a phone affordance for returning to a
            // hidden chat screen — meaningless when both screens are visible at once.
            showsCallBubble: layoutMode == .fullScreen,
            skipTransferredSCHandling: skipTransferredSCHandling,
            replaceExistingEnqueueing: replaceExistingEnqueueing
        )

        engagement = .call(
            callViewController,
            chatViewController,
            .none,
            call
        )

        switch layoutMode {
        case .fullScreen:
            navigationPresenter.setViewControllers(
                [callViewController],
                animated: animated
            )
        case .sidePanel:
            splitViewController?.setLeading(callViewController)
            navigationPresenter.setViewControllers(
                [chatViewController],
                animated: animated
            )
        }
    }

    deinit {
        environment.log.prefixed(Self.self).info("\(Self.self) is deallocated.")
    }
}

extension EngagementCoordinator {
    func end(
        surveyPresentation: SecureConversations.Coordinator.DelegateEvent.SurveyPresentation,
        dismissalCompletion: (() -> Void)? = nil
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
                self?.resetEngagementState()
                // If engagement was ended then pass `ended` event. This
                // initiates sending `ended` event to integrators.
                // Otherwise, pass `closed` meaning that Glia screen was closed
                // without having an engagement. This does not send `ended` event to integrators.
                if engagementEnded {
                    self?.delegate?(.ended)
                } else {
                    self?.delegate?(.closed)
                }
                dismissalCompletion?()
            }
        }

        let endedEngagement = interactor.takeSurveyEligibleEngagement()
        guard let engagement = endedEngagement,
                engagement.actionOnEnd == .showSurvey,
                surveyPresentation == .presentSurvey else {
            environment.log.prefixed(Self.self).info(
                "Dismiss Glia screen without showing survey. On end action: \(String(describing: endedEngagement?.actionOnEnd))"
            )
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
                environment.log.prefixed(Self.self).info("Survey loaded with no content")
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

    private func resetEngagementState() {
        engagement = .none
        navigationPresenter.setViewControllers([], animated: false)
        splitViewController?.setPanel(nil)
        splitViewController?.setLeading(nil)
        removeAllCoordinators()
        engagementLaunching = .direct(kind: .none)
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
        self.removeBubbleWindow()
        self.presentOverEngagement(viewController, animated: true)
    }

    /// Presents `viewController` above whatever Glia surface is currently on
    /// screen. `GliaPresenter` targets the host window, which in side-panel
    /// mode sits *below* the panel window, so anything presented there would be
    /// partially covered by the panel; presenting on the split container keeps
    /// it above both panes while `EngagementPanelWindow.hitTest` still routes
    /// touches to it.
    private func presentOverEngagement(
        _ viewController: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        switch layoutMode {
        case .fullScreen:
            gliaPresenter.present(viewController, animated: animated, completion: completion)
        case .sidePanel:
            guard let splitViewController else {
                gliaPresenter.present(viewController, animated: animated, completion: completion)
                return
            }
            var presenter: UIViewController = splitViewController
            while let presented = presenter.presentedViewController {
                presenter = presented
            }
            presenter.present(viewController, animated: animated, completion: completion)
        }
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
            layoutMode: layoutMode,
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
                    minimizeBubble(animated: true)
                }
            case .call(let callViewController, _, let upgradedFrom, _):
                switch layoutMode {
                case .sidePanel:
                    // Chat and call are both visible side by side; there is no
                    // navigation stack relationship between them to unwind.
                    minimizeBubble(animated: true)
                case .fullScreen:
                    if upgradedFrom == .chat {
                        minimizeBubble(animated: true)
                    } else {
                        navigationPresenter.pop(to: callViewController, animated: true)
                    }
                }
            default:
                popCoordinator()
                end(surveyPresentation: .presentSurvey)
            }
        case let .openLink(link):
            presentSafariViewController(for: link)
        case .engaged(let operatorImageUrl):
            setBubbleKind(.userImage(url: operatorImageUrl))
        case .mediaUpgradeAccepted(let offer, let answer):
            chatMediaUpgradeAccepted(offer: offer, answer: answer)
        case .secureTranscriptUpgradedToLiveChat(let chatViewController):
            upgradeSecureTranscriptToChat(chatViewController: chatViewController)
        case .call:
            // In side-panel mode the call is already visible in the leading
            // region, so there is nothing to navigate to.
            guard layoutMode == .fullScreen else { break }
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
            startAction: startAction,
            environment: .create(with: environment),
            layoutMode: layoutMode
        )
        coordinator.delegate = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .back:
                switch self.layoutMode {
                case .sidePanel:
                    // Chat and call are both visible side by side; there is no
                    // navigation stack relationship between them to unwind.
                    self.minimizeBubble(animated: true)
                case .fullScreen:
                    switch self.engagement {
                    case .call(_, let chatViewController, let upgradedFrom, _):
                        if upgradedFrom == .chat {
                            self.navigationPresenter.pop(to: chatViewController, animated: true)
                        } else {
                            self.minimizeBubble(animated: true)
                        }
                    default:
                        break
                    }
                }
            case let .openLink(link):
                self.presentSafariViewController(for: link)
            case .engaged(let operatorImageUrl):
                self.setBubbleKind(.userImage(url: operatorImageUrl))
            case .chat:
                // In side-panel mode the chat button is hidden, and chat is
                // already visible in the panel, so there is nothing to do.
                guard self.layoutMode == .fullScreen else { break }
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
                self.minimizeBubble(animated: true)
            case .finished:
                self.popCoordinator()
                self.end(surveyPresentation: .presentSurvey)
            case .visitorOnHoldUpdated(let isOnHold):
                self.setBubbleVisitorHoldState(isOnHold: isOnHold)
            }
        }
        pushCoordinator(coordinator)

        return coordinator.start(replaceExistingEnqueueing: replaceExistingEnqueueing)
    }

    private func makeGliaView(
        bubbleView: BubbleView,
        features: Features
    ) -> GliaViewController {
        GliaViewController(
            bubbleView: bubbleView,
            delegate: { [weak self] event in
                self?.delegateEvent(event)
            },
            sceneProvider: sceneProvider,
            features: features,
            environment: .create(
                with: environment,
                animate: makeAnimate()
            )
        )
    }

    private func makeBubblePresenter(
        bubbleView: BubbleView,
        features: Features
    ) -> BubblePresenter {
        BubblePresenter(
            bubbleView: bubbleView,
            delegate: { [weak self] event in
                self?.delegateEvent(event)
            },
            sceneProvider: sceneProvider,
            // Stealing key-window status is disruptive when the host app stays
            // visible and interactive beside the panel.
            becomesKeyWindow: false,
            features: features,
            environment: .create(
                with: environment,
                animate: makeAnimate()
            )
        )
    }

    private func makeAnimate() -> (
        _ animated: Bool,
        _ animations: @escaping () -> Void,
        _ completion: @escaping (
            Bool
        ) -> Void
    ) -> Void {
        { animated, animations, completion in
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
    }

    private func makePanelWindow(rootViewController: UIViewController) -> EngagementPanelWindow {
        let window: EngagementPanelWindow
        let windowScene = Self.resolveWindowScene(
            sceneProvider: sceneProvider,
            connectedScenes: environment.uiApplication.connectionScenes()
        )
        if let windowScene {
            window = EngagementPanelWindow(windowScene: windowScene)
        } else {
            window = EngagementPanelWindow(frame: environment.uiScreen.bounds())
        }
        window.rootViewController = rootViewController
        return window
    }

    /// Falls back to the app's foreground scene when the integrator has not
    /// supplied a `SceneProvider` — otherwise both layout-mode resolution and
    /// the panel window default to `.fullScreen`/a detached frame even on a
    /// qualifying iPad scene, since most integrators never set `sceneProvider`.
    /// An inactive foreground scene is accepted as a last resort because a cold
    /// launch from a push or an engagement restore can run before activation.
    static func resolveWindowScene(
        sceneProvider: SceneProvider?,
        connectedScenes: Set<UIScene>
    ) -> UIWindowScene? {
        if let windowScene = sceneProvider?.windowScene() {
            return windowScene
        }
        let windowScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        return windowScenes.first { $0.activationState == .foregroundActive }
            ?? windowScenes.first { $0.activationState == .foregroundInactive }
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
                isWindowVisible: isWindowVisible,
                layoutMode: layoutMode,
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
            self.minimizeBubble(animated: true)
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
        switch layoutMode {
        case .fullScreen:
            guard let gliaViewController = gliaViewController else { return }
            gliaPresenter.present(gliaViewController, animated: animated) { [weak self] in
                self?.isWindowVisible.value = true
                completion?()
            }
        case .sidePanel:
            panelWindow?.isHidden = false
            isWindowVisible.value = true
            completion?()
        }
    }

    private func dismissGliaViewController(animated: Bool, completion: (() -> Void)? = nil) {
        switch layoutMode {
        case .fullScreen:
            guard let gliaViewController = gliaViewController else { return }
            gliaPresenter.dismiss(gliaViewController, animated: animated) { [weak self] in
                self?.isWindowVisible.value = false
                completion?()
            }
        case .sidePanel:
            // A hidden window must never stay key, or the host loses keyboard input.
            panelWindow?.resignKeyToHostWindow()
            panelWindow?.isHidden = true
            isWindowVisible.value = false
            completion?()
        }
    }
}

extension EngagementCoordinator {
    private func minimizeBubble(animated: Bool) {
        switch layoutMode {
        case .fullScreen:
            gliaViewController?.minimize(animated: animated)
        case .sidePanel:
            bubblePresenter?.minimize(animated: animated)
        }
    }

    private func maximizeBubble(animated: Bool) {
        switch layoutMode {
        case .fullScreen:
            gliaViewController?.maximize(animated: animated)
        case .sidePanel:
            bubblePresenter?.maximize(animated: animated)
        }
    }

    private func setBubbleKind(_ kind: BubbleKind) {
        switch layoutMode {
        case .fullScreen:
            gliaViewController?.bubbleKind = kind
        case .sidePanel:
            bubblePresenter?.bubbleKind = kind
        }
    }

    private func setBubbleVisitorHoldState(isOnHold: Bool) {
        switch layoutMode {
        case .fullScreen:
            gliaViewController?.setVisitorHoldState(isOnHold: isOnHold)
        case .sidePanel:
            bubblePresenter?.setVisitorHoldState(isOnHold: isOnHold)
        }
    }

    private func removeBubbleWindow() {
        switch layoutMode {
        case .fullScreen:
            gliaViewController?.removeBubbleWindow()
        case .sidePanel:
            bubblePresenter?.removeBubbleWindow()
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
            switch layoutMode {
            case .fullScreen:
                navigationPresenter.push(callViewController)
            case .sidePanel:
                splitViewController?.setLeading(callViewController)
            }

        case .call(let callViewController, let chatViewController, _, let call):
            call.upgrade(to: offer)
            engagement = .call(
                callViewController,
                chatViewController,
                .none,
                call
            )
            // In side-panel mode both the call and chat panes are already
            // visible; the existing call view controller reflects the
            // upgraded media kind via its own `Call` observers.
            if layoutMode == .fullScreen {
                navigationPresenter.setViewControllers(
                    [callViewController],
                    animated: true
                )
            }
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
            style: theme.webView.header
        )

        let props: WebViewController.Props = .init(
            link: link.url,
            header: headerProps,
            externalOpen: openBrowser
        )
        viewController.props = props
        presentOverEngagement(viewController, animated: true)
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
    func minimize(animated: Bool = true) {
        minimizeBubble(animated: animated)
    }

    func maximize() {
        maximizeBubble(animated: true)
    }
}
