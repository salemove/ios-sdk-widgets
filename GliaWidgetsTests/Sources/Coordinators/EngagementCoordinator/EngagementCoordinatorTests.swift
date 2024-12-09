import Foundation
import XCTest
@testable import GliaWidgets

final class EngagementCoordinatorTests: XCTestCase {
    var coordinator: EngagementCoordinator!

    override func setUp() {
        coordinator = createCoordinator()
    }

    override func tearDown() {
        coordinator.end()
        coordinator = nil
    }

    // Start

    func test_startText() throws {
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

        coordinator.interactor.currentEngagement = .mock(fetchSurvey: { _, completion in completion(.success(survey)) })
        coordinator.end(surveyPresentation: .doNotPresentSurvey)

        XCTAssertEqual(coordinator.navigationPresenter.viewControllers.count, 0)
        XCTAssertEqual(coordinator.engagementLaunching.currentKind, .none)
        XCTAssertTrue(calledEvents.contains(.ended))
    }

    // Chat coordinator delegate events

    func test_chatCoordinatorBackOnInteractorStateNone() {
        coordinator.start()
        
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

        coordinator.interactor.state = .enqueueing(.text)

        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator
        chatCoordinator?.delegate?(.back)

        XCTAssertEqual(calledEvents.last, .minimized)
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

        XCTAssertNotNil(coordinator.navigationPresenter.viewControllers.first as? EngagementViewController)
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

        XCTAssertEqual(calledEvents.last, .minimized)
    }

    func test_chatCoordinatorEngaged() throws {
        coordinator.start()

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

        let chatCoordinator = coordinator.coordinators.last as? ChatCoordinator
        chatCoordinator?.delegate?(.finished)

        let flowCoordinator = coordinator.coordinators.last

        XCTAssertNil(flowCoordinator)
    }
}

extension EngagementCoordinatorTests {
    func createCoordinator(
        withKind engagementKind: EngagementKind = .chat
    ) -> EngagementCoordinator {
        return createCoordinator(with: .direct(kind: engagementKind))
    }

    func createCoordinator(
        with engagementLaunching: EngagementCoordinator.EngagementLaunching
    ) -> EngagementCoordinator {
        var env = EngagementCoordinator.Environment.mock
        env.dismissManager.dismissViewControllerAnimateWithCompletion = { _, _, completion in
            completion?()
        }
        let window = UIWindow(frame: .zero)
        window.rootViewController = .init()
        window.makeKeyAndVisible()
        env.uiApplication.windows = { [window] }
        return EngagementCoordinator(
            interactor: .mock(),
            viewFactory: .mock(),
            sceneProvider: MockedSceneProvider(),
            engagementLaunching: engagementLaunching,
            screenShareHandler: .mock,
            features: [],
            environment: env
        )
    }
}
