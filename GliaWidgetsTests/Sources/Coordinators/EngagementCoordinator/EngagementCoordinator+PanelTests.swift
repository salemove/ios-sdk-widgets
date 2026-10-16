import Foundation
import XCTest
@testable import GliaWidgets

extension EngagementCoordinatorTests {
    func test_fullScreenModeCreatesGliaViewControllerAndNoPanelWindow() throws {
        coordinator.start()

        XCTAssertNotNil(coordinator.gliaViewController)
        XCTAssertNil(coordinator.panelWindow)
        XCTAssertNil(coordinator.splitViewController)
    }

    func test_sidePanelModeExposesSplitContainerWithNavigationControllerInPanel() throws {
        let coordinator = createPanelCoordinator()
        coordinator.start()

        let splitViewController = try XCTUnwrap(coordinator.splitViewController)
        XCTAssertTrue(splitViewController.panelViewController === coordinator.navigationPresenter.navigationController)
        XCTAssertNil(splitViewController.leadingViewController)
        XCTAssertNil(coordinator.gliaViewController)
        XCTAssertNotNil(coordinator.panelWindow)
    }

    // Alerts the chat raises over itself must dim the panel only, so the panel's
    // navigation stack opts into contained alerts; in full-screen mode nothing changes.
    func test_sidePanelModeNavigationControllerConfinesAlerts() throws {
        let coordinator = createPanelCoordinator()
        coordinator.start()

        let navigationController = try XCTUnwrap(
            coordinator.navigationPresenter.navigationController as? NavigationController
        )
        XCTAssertTrue(navigationController.confinesAlertsToOwnBounds)
        XCTAssertTrue(navigationController.providesPresentationContextTransitionStyle)
    }

    func test_fullScreenModeNavigationControllerDoesNotConfineAlerts() throws {
        coordinator.start()

        let navigationController = try XCTUnwrap(
            coordinator.navigationPresenter.navigationController as? NavigationController
        )
        XCTAssertFalse(navigationController.confinesAlertsToOwnBounds)
    }

    func test_sidePanelModeMinimizeThenMaximizeEmitsEvents() throws {
        let coordinator = createPanelCoordinator()
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []
        let maximizedExpectation = expectation(description: "maximized")
        coordinator.delegate = { event in
            calledEvents.append(event)
            if event == .maximized {
                maximizedExpectation.fulfill()
            }
        }

        coordinator.start(maximize: false)

        coordinator.minimize()
        XCTAssertEqual(calledEvents.last, .minimized)

        coordinator.maximize()
        wait(for: [maximizedExpectation], timeout: 1)
        XCTAssertEqual(calledEvents.last, .maximized)
    }

    func test_sidePanelModeEndClearsSplitContainerAndNavStack() throws {
        let coordinator = createPanelCoordinator()
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        let survey: CoreSdkClient.Survey = try .mock()
        coordinator.start()

        let engagement: CoreSdkClient.Engagement = .mock(fetchSurvey: { _, completion in completion(.success(survey)) })
        coordinator.interactor.setCurrentEngagement(engagement)
        coordinator.interactor.state = .ended(.byVisitor)
        coordinator.end(surveyPresentation: .doNotPresentSurvey)

        XCTAssertEqual(coordinator.navigationPresenter.viewControllers.count, 0)
        XCTAssertNil(coordinator.splitViewController?.panelViewController)
        XCTAssertTrue(calledEvents.contains(.ended))
    }

    // A call takes the whole scene: the chat stays the panel's content but the
    // panel is collapsed until the call's chat button reveals it.
    func test_sidePanelModeVideoCallPutsCallInLeadingAndCollapsesChatPanel() throws {
        let coordinator = createPanelCoordinator(withKind: .videoCall)
        coordinator.start()

        let splitViewController = try XCTUnwrap(coordinator.splitViewController)
        XCTAssertTrue(splitViewController.leadingViewController is CallViewController)
        XCTAssertTrue(splitViewController.panelViewController === coordinator.navigationPresenter.navigationController)
        XCTAssertTrue(coordinator.navigationPresenter.viewControllers.first is ChatViewController)
        XCTAssertTrue(splitViewController.isPanelCollapsed)
    }

    // While a call is active the call header owns End, so the revealed chat
    // header keeps only back; a chat-only engagement keeps its full header.
    func test_sidePanelModeCallHidesChatHeaderEndControlsButChatOnlyDoesNot() throws {
        let callCoordinator = createPanelCoordinator(withKind: .videoCall)
        callCoordinator.start()
        let chatBesideCall = try XCTUnwrap(callCoordinator.navigationPresenter.viewControllers.first as? ChatViewController)
        let headerBesideCall = try XCTUnwrap((chatBesideCall.view as? ChatView)?.header)
        XCTAssertTrue(headerBesideCall.areEndControlsHidden)
        XCTAssertFalse(headerBesideCall.areControlsHidden)

        let chatCoordinator = createPanelCoordinator(withKind: .chat)
        chatCoordinator.start()
        let chatOnly = try XCTUnwrap(chatCoordinator.navigationPresenter.viewControllers.first as? ChatViewController)
        let chatOnlyHeader = try XCTUnwrap((chatOnly.view as? ChatView)?.header)
        XCTAssertFalse(chatOnlyHeader.areEndControlsHidden)
    }

    func test_sidePanelModeCallChatButtonTogglesCollapsedPanel() throws {
        let coordinator = createPanelCoordinator(withKind: .videoCall)
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []
        coordinator.delegate = { calledEvents.append($0) }
        coordinator.start()
        let splitViewController = try XCTUnwrap(coordinator.splitViewController)
        let callCoordinator = try XCTUnwrap(coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator)
        XCTAssertTrue(splitViewController.isPanelCollapsed)

        callCoordinator.delegate?(.chat)
        XCTAssertFalse(splitViewController.isPanelCollapsed)

        callCoordinator.delegate?(.chat)
        XCTAssertTrue(splitViewController.isPanelCollapsed)

        XCTAssertFalse(calledEvents.contains(.minimized))
        XCTAssertFalse(try XCTUnwrap(coordinator.panelWindow).isHidden)
    }

    func test_sidePanelModeMinimizeAndMaximizePreserveRevealedPanel() throws {
        let coordinator = createPanelCoordinator(withKind: .videoCall)
        coordinator.start()
        let splitViewController = try XCTUnwrap(coordinator.splitViewController)
        let callCoordinator = try XCTUnwrap(coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator)
        callCoordinator.delegate?(.chat)
        XCTAssertFalse(splitViewController.isPanelCollapsed)

        coordinator.minimize()
        XCTAssertTrue(try XCTUnwrap(coordinator.panelWindow).isHidden)
        XCTAssertFalse(splitViewController.isPanelCollapsed)

        let maximized = expectation(description: "maximized")
        coordinator.delegate = { if $0 == .maximized { maximized.fulfill() } }
        coordinator.maximize()
        wait(for: [maximized], timeout: 1)
        XCTAssertFalse(try XCTUnwrap(coordinator.panelWindow).isHidden)
        XCTAssertFalse(splitViewController.isPanelCollapsed)
    }

    func test_sidePanelModeChatToCallUpgradeInstallsCallInLeadingAndLeavesChatInPanel() throws {
        let coordinator = createPanelCoordinator(withKind: .chat)
        coordinator.start()

        let chatCoordinator = try XCTUnwrap(coordinator.coordinators.first { $0 is ChatCoordinator } as? ChatCoordinator)
        let mediaUpgradeOffer = try XCTUnwrap(
            CoreSdkClient.MediaUpgradeOffer(type: .audio, direction: .twoWay)
        )
        chatCoordinator.delegate?(
            .mediaUpgradeAccepted(
                offer: mediaUpgradeOffer,
                answer: { _, success in success?(true, nil) }
            )
        )

        let splitViewController = try XCTUnwrap(coordinator.splitViewController)
        XCTAssertTrue(splitViewController.leadingViewController is CallViewController)
        XCTAssertTrue(coordinator.navigationPresenter.viewControllers.first is ChatViewController)
        XCTAssertTrue(splitViewController.isPanelCollapsed)
    }

    func test_sidePanelModeAudioToVideoUpgradeDoesNotDiscardChatViewController() throws {
        let coordinator = createPanelCoordinator(withKind: .audioCall)
        coordinator.start()

        let chatViewControllerBeforeUpgrade = coordinator.navigationPresenter.viewControllers.first as? ChatViewController
        XCTAssertNotNil(chatViewControllerBeforeUpgrade)

        let chatCoordinator = try XCTUnwrap(coordinator.coordinators.first { $0 is ChatCoordinator } as? ChatCoordinator)
        let videoUpgradeOffer = try XCTUnwrap(
            CoreSdkClient.MediaUpgradeOffer(type: .video, direction: .twoWay)
        )
        chatCoordinator.delegate?(
            .mediaUpgradeAccepted(
                offer: videoUpgradeOffer,
                answer: { _, success in success?(true, nil) }
            )
        )

        XCTAssertTrue(coordinator.navigationPresenter.viewControllers.first === chatViewControllerBeforeUpgrade)
    }

    func test_sidePanelModeCallFlowChatDoesNotTriggerSecondEnqueue() throws {
        let coordinator = createPanelCoordinator(withKind: .videoCall)
        coordinator.start()

        // The call's own explicit enqueue must be the only one — the now-visible
        // call-flow chat view controller is still built with `startAction: .none`,
        // so it must not also enqueue for `.chat`.
        XCTAssertEqual(coordinator.interactor.state, .enqueueing(.videoCall))
        XCTAssertTrue(coordinator.navigationPresenter.viewControllers.first is ChatViewController)
    }

    // The call's minimize button hides the whole panel window, while back on the
    // revealed chat panel only collapses the panel behind the call.
    func test_sidePanelModeCallMinimizeHidesPanelWindow() throws {
        let coordinator = createPanelCoordinator(withKind: .videoCall)
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []
        coordinator.delegate = { calledEvents.append($0) }
        coordinator.start()
        coordinator.interactor.state = .engaged(nil)
        let panelWindow = try XCTUnwrap(coordinator.panelWindow)
        XCTAssertFalse(panelWindow.isHidden)

        let callCoordinator = try XCTUnwrap(coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator)
        callCoordinator.delegate?(.minimize)

        XCTAssertTrue(panelWindow.isHidden)
        XCTAssertEqual(calledEvents.last, .minimized)
    }

    func test_sidePanelModeChatBackDuringCallCollapsesPanelWithoutMinimizing() throws {
        let coordinator = createPanelCoordinator(withKind: .videoCall)
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []
        coordinator.delegate = { calledEvents.append($0) }
        coordinator.start()
        coordinator.interactor.state = .engaged(nil)
        let splitViewController = try XCTUnwrap(coordinator.splitViewController)
        let callCoordinator = try XCTUnwrap(coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator)
        callCoordinator.delegate?(.chat)
        XCTAssertFalse(splitViewController.isPanelCollapsed)

        let chatCoordinator = try XCTUnwrap(coordinator.coordinators.first { $0 is ChatCoordinator } as? ChatCoordinator)
        chatCoordinator.delegate?(.back)

        XCTAssertTrue(splitViewController.isPanelCollapsed)
        XCTAssertFalse(try XCTUnwrap(coordinator.panelWindow).isHidden)
        XCTAssertFalse(calledEvents.contains(.minimized))
    }

    func test_sidePanelModeEndPresentsSurveyAboveThePanel() throws {
        let survey: CoreSdkClient.Survey = try .mock()
        let engagement = CoreSdkClient.Engagement.mock(
            fetchSurvey: { _, completion in completion(.success(survey)) },
            actionOnEnd: .showSurvey
        )
        var coreSdkClient = CoreSdkClient.mock
        coreSdkClient.getCurrentEngagement = { engagement }
        let interactor = Interactor.mock(
            environment: .init(coreSdk: coreSdkClient, queuesMonitor: .mock(), gcd: .mock, log: .mock)
        )
        let coordinator = createPanelCoordinator(interactor: interactor)
        coordinator.start()
        interactor.onEngagementChanged(engagement)
        interactor.end(with: .visitorHungUp)

        coordinator.end(surveyPresentation: .presentSurvey)

        // `GliaPresenter` targets the host window, which sits *below* the panel
        // window; the survey must instead be presented on the split container.
        let splitViewController = try XCTUnwrap(coordinator.splitViewController)
        XCTAssertTrue(splitViewController.presentedViewController is Survey.ViewController)
        XCTAssertNil(coordinator.gliaPresenter.window?.rootViewController?.presentedViewController)
    }

    // Most integrators never supply a `SceneProvider`; without a fallback here,
    // `layoutMode` resolution and the panel window would silently default to
    // `.fullScreen`/a detached frame even on a qualifying iPad scene.
    func test_resolveWindowSceneFallsBackToConnectedSceneWhenSceneProviderIsNil() throws {
        let resolved = EngagementCoordinator.resolveWindowScene(
            sceneProvider: nil,
            connectedScenes: UIApplication.shared.connectedScenes
        )
        XCTAssertNotNil(resolved)
    }

    func test_resolveWindowSceneFallsBackToConnectedSceneWhenSceneProviderReturnsNil() throws {
        let resolved = EngagementCoordinator.resolveWindowScene(
            sceneProvider: NilSceneProvider(),
            connectedScenes: UIApplication.shared.connectedScenes
        )
        XCTAssertNotNil(resolved)
    }

    func test_resolveWindowSceneIsNilWithoutProviderOrConnectedScenes() throws {
        let resolved = EngagementCoordinator.resolveWindowScene(
            sceneProvider: NilSceneProvider(),
            connectedScenes: []
        )
        XCTAssertNil(resolved)
    }

    func test_resolveWindowScenePrefersNonNilSceneProvider() throws {
        let realScene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let resolved = EngagementCoordinator.resolveWindowScene(
            sceneProvider: StubSceneProvider(scene: realScene),
            connectedScenes: []
        )
        XCTAssertEqual(resolved, realScene)
    }
}

private final class NilSceneProvider: SceneProvider {
    func windowScene() -> UIWindowScene? { nil }
}

private final class StubSceneProvider: SceneProvider {
    private let scene: UIWindowScene
    init(scene: UIWindowScene) { self.scene = scene }
    func windowScene() -> UIWindowScene? { scene }
}

extension EngagementCoordinatorTests {
    func createPanelCoordinator(
        withKind engagementKind: EngagementKind = .chat,
        interactor: Interactor = .mock()
    ) -> EngagementCoordinator {
        var env = EngagementCoordinator.Environment.mock()
        env.dismissManager.dismissViewControllerAnimateWithCompletion = { _, _, completion in
            completion?()
        }
        env.resolveLayoutMode = { _ in .sidePanel }
        // The panel window needs a real scene so that presenting on its root
        // view controller works the way it does in the app.
        env.uiApplication.connectionScenes = { UIApplication.shared.connectedScenes }
        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        env.uiApplication.windows = { [window] }
        return EngagementCoordinator(
            interactor: interactor,
            viewFactory: .mock(),
            sceneProvider: MockedSceneProvider(),
            engagementLaunching: .direct(kind: engagementKind),
            features: [],
            engagementRestorationState: { .none },
            environment: env
        )
    }
}
