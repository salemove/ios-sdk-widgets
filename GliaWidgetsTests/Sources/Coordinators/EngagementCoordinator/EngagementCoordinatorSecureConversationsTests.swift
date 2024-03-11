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

        callAfterTimeout {
            XCTAssertNil(flowCoordinator)
            XCTAssertEqual(coordinator.coordinators.count, 0)
        }
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

        callAfterTimeout {
            XCTAssertTrue(calledEvents.contains(.minimized))
        }
    }

    func test_secureConversationsDelegateChat() throws {
        coordinator = createCoordinator(withKind: .messaging(.welcome))

        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()
        try showGliaViewController()

        let secureConversationsCoordinator = coordinator.coordinators.first as? SecureConversations.Coordinator
        secureConversationsCoordinator?.delegate?(.chat(.back))

        callAfterTimeout {
            XCTAssertTrue(calledEvents.contains(.minimized))
        }
    }
}
