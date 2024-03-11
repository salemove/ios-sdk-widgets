import Foundation
import XCTest
@testable import GliaWidgets

final class EngagementCoordinatorTests: XCTestCase {
    var coordinator: EngagementCoordinator!
    var closuresForTearDown: [() -> Void] = []

    override func setUp() {
        UIView.setAnimationsEnabled(false)
        coordinator = createCoordinator()
    }

    override func tearDown() {
        for closure in closuresForTearDown {
            closure()
        }

        coordinator.end()
        coordinator = nil

        UIView.setAnimationsEnabled(true)
    }

    func createCoordinator(
        withKind engagementKind: EngagementKind = .chat
    ) -> EngagementCoordinator {
        return EngagementCoordinator(
            interactor: .mock(),
            viewFactory: .mock(),
            sceneProvider: MockedSceneProvider(),
            engagementKind: engagementKind,
            screenShareHandler: .mock,
            features: [],
            environment: .mock
        )
    }

    // Start

    func test_startText() throws {
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        XCTAssertEqual(coordinator.interactor.state, .enqueueing(.text))
        let viewController = coordinator.navigationPresenter.viewControllers.first as? ChatViewController
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator.gliaViewController)

        XCTAssertEqual(calledEvents.count, 1)
        XCTAssertEqual(calledEvents.first, .started)
    }

    func test_startAudioCall() throws {
        let coordinator = createCoordinator(withKind: .audioCall)
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        XCTAssertEqual(coordinator.interactor.state, .enqueueing(.audio))
        let viewController = coordinator.navigationPresenter.viewControllers.first as? CallViewController
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator.gliaViewController)

        XCTAssertEqual(calledEvents.count, 1)
        XCTAssertEqual(calledEvents.first, .started)
    }

    func test_startVideoCall() throws {
        let coordinator = createCoordinator(withKind: .videoCall)
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        XCTAssertEqual(coordinator.interactor.state, .enqueueing(.video))
        let viewController = coordinator.navigationPresenter.viewControllers.first as? CallViewController
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator.gliaViewController)

        XCTAssertEqual(calledEvents.count, 1)
        XCTAssertEqual(calledEvents.first, .started)
    }

    func test_startMessagingWelcome() throws {
        let coordinator = createCoordinator(withKind: .messaging(.welcome))
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        XCTAssertEqual(coordinator.interactor.state, .none)
        let viewController = coordinator.navigationPresenter.viewControllers.first as? SecureConversations.WelcomeViewController
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator.gliaViewController)

        XCTAssertEqual(calledEvents.count, 1)
        XCTAssertEqual(calledEvents.first, .started)
    }

    func test_startMessagingChatTranscript() throws {
        let coordinator = createCoordinator(withKind: .messaging(.chatTranscript))
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        XCTAssertEqual(coordinator.interactor.state, .none)
        let viewController = coordinator.navigationPresenter.viewControllers.first as? ChatViewController
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator.gliaViewController)

        XCTAssertEqual(calledEvents.count, 1)
        XCTAssertEqual(calledEvents.first, .started)
    }

    // End

    func test_endChatWithSurvey() throws {
        let survey: CoreSdkClient.Survey = try .mock()
        coordinator.interactor.currentEngagement = .mock(fetchSurvey: { _, completion in completion(.success(survey)) })
        coordinator.end()

        let surveyViewController = coordinator.gliaPresenter.topMostViewController as? Survey.ViewController
        XCTAssertNotNil(surveyViewController)
    }

    func test_endChatWithoutSurvey() throws {
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        let survey: CoreSdkClient.Survey = try .mock()
        coordinator.start()

        try showGliaViewController()

        coordinator.interactor.currentEngagement = .mock(fetchSurvey: { _, completion in completion(.success(survey)) })
        coordinator.end(surveyPresentation: .doNotPresentSurvey)

        callAfterTimeout {
            XCTAssertEqual(self.coordinator.navigationPresenter.viewControllers.count, 0)
            XCTAssertEqual(self.coordinator.engagementKind, .none)
            XCTAssertTrue(calledEvents.contains(.ended))
        }
    }

    // Chat coordinator delegate events

    func test_chatCoordinatorBackOnInteractorStateNone() {
        coordinator.start()
        coordinator.interactor.state = .none
        
        XCTAssertNotEqual(coordinator.coordinators.count, 0)

        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator

        chatCoordinator?.delegate?(.back)
        let flowCoordinator = coordinator.coordinators.last

        XCTAssertNil(flowCoordinator)
    }

    func test_chatCoordinatorBackOnInteractorStateAny() {
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator
        chatCoordinator?.delegate?(.back)
        
        callAfterTimeout {
            XCTAssertEqual(calledEvents.last, .minimized)
        }
    }

    func test_chatCoordinatorBackCall() {
        coordinator = createCoordinator(withKind: .audioCall)

        var calledEvents: [EngagementCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator
        chatCoordinator?.delegate?(.back)

        callAfterTimeout {
            XCTAssertNotNil(coordinator.navigationPresenter.viewControllers.first as? EngagementViewController)
        }
    }

    func test_chatCoordinatorBackCallFromChat() throws {
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator

        let mediaUpgradeOffer = try! CoreSdkClient.MediaUpgradeOffer(type: .audio, direction: .twoWay)
        chatCoordinator?.delegate?(
            .mediaUpgradeAccepted(
                offer: mediaUpgradeOffer,
                answer: { answer, success in success?(true, nil) }
            )
        )
        chatCoordinator?.delegate?(.back)

        callAfterTimeout {
            XCTAssertEqual(calledEvents.last, .minimized)
        }
    }

    func test_chatCoordinatorEngaged() throws {
        coordinator.start()

        try showGliaViewController()
        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator
        chatCoordinator?.delegate?(.engaged(operatorImageUrl: URL.mock.absoluteString))

        switch coordinator.gliaViewController!.bubbleKind {
        case .userImage(let url):
            XCTAssertEqual(url, URL.mock.absoluteString)
        default: XCTFail()
        }
    }

    func test_chatCoordinatorSecureTranscriptUpgradedToLiveChat() throws {
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        try showGliaViewController()
        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator
        chatCoordinator?.delegate?(.finished)

        let flowCoordinator = coordinator.coordinators.last

        callAfterTimeout {
            XCTAssertNil(flowCoordinator)
        }
    }
}

extension EngagementCoordinatorTests {
    var currentWindow: UIWindow? {
        get throws {
            let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
            return scene.windows.first { !($0 is BubbleWindow) }
        }
    }
    // Some actions in the coordinator require the view controller to be
    // present in the window hierarchy to work. Also restores the old
    // view controller on tearDown.
    func showGliaViewController() throws {
        let window = try currentWindow
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = coordinator.gliaViewController

        closuresForTearDown.append {
            window?.rootViewController = oldRootViewController
        }
    }

    // Some of the actions in these tests include waiting for animations or dismissals
    // of view controllers. These fail if the asserts are done right away.
    func callAfterTimeout(_ callback: () -> Void) {
        let expectation = expectation(description: "Wait")
        let result = XCTWaiter.wait(for: [expectation], timeout: 0.5)

        if result == .timedOut {
            callback()
        }
    }
}
