import Foundation
import XCTest
@testable import GliaWidgets

extension EngagementCoordinatorTests {
    // MARK: - Start
    func test_secureConversationsWelcome() {
        coordinator = createCoordinator(withKind: .messaging(.welcome))
        coordinator.start()

        let viewController = coordinator.navigationPresenter.viewControllers.first as? SecureConversations.WelcomeViewController


        XCTAssertNotNil(viewController)
        XCTAssertEqual(coordinator.interactor.state, .none)
    }

    // MARK: - Delegate

    func test_secureConversationsDelegateClosedTapped() {
        coordinator = createCoordinator(withKind: .messaging(.welcome))
        coordinator.start()

        let secureConversationsCoordinator = coordinator.coordinators.first as? SecureConversations.Coordinator
        secureConversationsCoordinator?.delegate?(.closeTapped(.doNotPresentSurvey))

        let flowCoordinator = coordinator.coordinators.last

        XCTAssertNil(flowCoordinator)
        XCTAssertEqual(coordinator.coordinators.count, 0)
    }

    func test_secureConversationsDelegateBackTapped() throws {
        coordinator = createCoordinator(withKind: .messaging(.welcome))

        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }
        coordinator.start()

        let secureConversationsCoordinator = coordinator.coordinators.first as? SecureConversations.Coordinator
        secureConversationsCoordinator?.delegate?(.backTapped)

        XCTAssertTrue(calledEvents.contains(.minimized))
    }

    func test_secureConversationsDelegateChat() throws {
        coordinator = createCoordinator(withKind: .messaging(.welcome))

        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        let secureConversationsCoordinator = coordinator.coordinators.first as? SecureConversations.Coordinator
        secureConversationsCoordinator?.delegate?(.chat(.back))

        XCTAssertTrue(calledEvents.contains(.minimized))
    }

    // MARK: - Leave Conversation
    func test_leaveCurrentConversationChangesEngagementKindToInitialOne() throws {
        coordinator = createCoordinator(with: .indirect(
            kind: .messaging(.chatTranscript),
            initialKind: .videoCall
        ))
        coordinator.start()

        let subCoordinator = try XCTUnwrap(coordinator.coordinators.first as? SecureConversations.Coordinator)

        XCTAssertEqual(coordinator.engagementLaunching.currentKind, .messaging(.chatTranscript))
        XCTAssertEqual(coordinator.engagementLaunching.initialKind, .videoCall)
        XCTAssertTrue(subCoordinator.coordinatorEnvironment.shouldShowLeaveSecureConversationDialog(.transcriptOpened))

        subCoordinator.coordinatorEnvironment.leaveCurrentSecureConversation(true)

        XCTAssertEqual(coordinator.engagementLaunching.currentKind, .videoCall)
        XCTAssertFalse(subCoordinator.coordinatorEnvironment.shouldShowLeaveSecureConversationDialog(.transcriptOpened))
    }

    // MARK: - Leave Conversation
    func test_leaveCurrentConversationDeclineSetsEngagementKindToMessaging() throws {
        coordinator = createCoordinator(with: .indirect(
            kind: .messaging(.chatTranscript),
            initialKind: .videoCall
        ))
        coordinator.start()

        let subCoordinator = try XCTUnwrap(coordinator.coordinators.first as? SecureConversations.Coordinator)

        XCTAssertEqual(coordinator.engagementLaunching.currentKind, .messaging(.chatTranscript))
        XCTAssertEqual(coordinator.engagementLaunching.initialKind, .videoCall)
        XCTAssertTrue(subCoordinator.coordinatorEnvironment.shouldShowLeaveSecureConversationDialog(.transcriptOpened))

        subCoordinator.coordinatorEnvironment.leaveCurrentSecureConversation(false)

        XCTAssertEqual(coordinator.engagementLaunching.currentKind, .messaging(.chatTranscript))
        XCTAssertFalse(subCoordinator.coordinatorEnvironment.shouldShowLeaveSecureConversationDialog(.transcriptOpened))
    }
}
