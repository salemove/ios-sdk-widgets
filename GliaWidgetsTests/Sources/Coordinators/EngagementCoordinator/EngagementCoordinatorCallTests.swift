import Foundation
import XCTest
@testable import GliaWidgets

extension EngagementCoordinatorTests {
    // MARK: - Start
    func test_call() {
        coordinator = createCoordinator(withKind: .audioCall)
        coordinator.start()
        
        let viewController = coordinator.navigationPresenter.viewControllers.first as? CallViewController

        XCTAssertNotNil(viewController)
        XCTAssertEqual(coordinator.interactor.state, .enqueueing(.audio))
    }

    func test_video() {
        coordinator = createCoordinator(withKind: .videoCall)
        coordinator.start()

        let viewController = coordinator.navigationPresenter.viewControllers.first as? CallViewController

        XCTAssertNotNil(viewController)
        XCTAssertEqual(coordinator.interactor.state, .enqueueing(.video))
    }

    // MARK: - Delegate

    func test_callDelegateBack() throws {
        coordinator = createCoordinator(withKind: .videoCall)
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        let callCoordinator = coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator
        callCoordinator?.delegate?(.back)

        callAfterTimeout {
            XCTAssertTrue(calledEvents.contains(.minimized))
        }
    }

    func test_callDelegateBackCallFromChat() throws {
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        let chatCoordinator = coordinator.coordinators.first { $0 is ChatCoordinator } as? ChatCoordinator

        let mediaUpgradeOffer = try CoreSdkClient.MediaUpgradeOffer(type: .audio, direction: .twoWay)
        chatCoordinator?.delegate?(
            .mediaUpgradeAccepted(
                offer: mediaUpgradeOffer,
                answer: { answer, success in success?(true, nil) }
            )
        )

        let callCoordinator = coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator
        callCoordinator?.delegate?(.back)

        callAfterTimeout {
            let topmostViewController = coordinator.navigationPresenter.viewControllers.first as? ChatViewController

            XCTAssertNotNil(topmostViewController)
        }
    }

    func test_callDelegateEngaged() throws {
        coordinator = createCoordinator(withKind: .videoCall)
        
        coordinator.start()

        try showGliaViewController()
        let callCoordinator =  try XCTUnwrap(coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator)

        callCoordinator.delegate?(.engaged(operatorImageUrl: URL.mock.absoluteString))

        switch coordinator.gliaViewController!.bubbleKind {
        case .userImage(let url):
            XCTAssertEqual(url, URL.mock.absoluteString)
        default: XCTFail()
        }
    }

    func test_callDelegateMinimize() throws {
        coordinator = createCoordinator(withKind: .videoCall)
        var calledEvents: [EngagementCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start()

        let callCoordinator = coordinator.coordinators.first { $0 is CallCoordinator } as? CallCoordinator
        callCoordinator?.delegate?(.minimize)

        callAfterTimeout {
            XCTAssertEqual(calledEvents.last, .minimized)
        }
    }
}
