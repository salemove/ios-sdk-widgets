import Foundation
import XCTest
@testable import GliaWidgets

final class CallCoordinatorTests: XCTestCase {
    var coordinator: CallCoordinator!

    override func setUpWithError() throws {
        let offer = try CoreSdkClient.MediaUpgradeOffer(
            type: .audio,
            direction: .twoWay
        )

        let startAction = CallViewModel.StartAction.call(
            offer: offer,
            answer: { _, _ in }
        )

        coordinator = CallCoordinator(
            interactor: .mock(),
            viewFactory: .mock(),
            navigationPresenter: NavigationPresenter(with: NavigationController()),
            call: .mock(),
            unreadMessages: .init(with: 0),
            screenShareHandler: .mock,
            startAction: startAction,
            environment: .mock
        )
    }

    func test_startGeneratesCallViewController() {
        let viewController = coordinator.start()

        XCTAssertNotNil(viewController)
    }

    // Delegate

    func test_delegateChat() throws {
        var calledEvents: [CallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start().viewModel.delegate?(.chat)

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .chat: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    func test_delegateMinimize() throws {
        var calledEvents: [CallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start().viewModel.delegate?(.minimize)

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .minimize: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    func test_delegateVisitorOnHoldUpdated() throws {
        var calledEvents: [CallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start().viewModel.delegate?(.visitorOnHoldUpdated(isOnHold: true))

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .visitorOnHoldUpdated: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    // Engagement delegate

    func test_engagementDelegateVisitorOnHoldUpdated() throws {
        var calledEvents: [CallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start().viewModel.engagementDelegate?(.back)

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .back: XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    func test_engagementDelegateOpenLink() throws {
        var calledEvents: [CallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        let link: WebViewController.Link = (title: "", url: URL.mock)
        coordinator.start().viewModel.engagementDelegate?(.openLink(link))

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .openLink(let openedLink): XCTAssertEqual(link.url, openedLink.url)
        default: XCTFail()
        }
    }

    func test_engagementDelegateEngaged() throws {
        var calledEvents: [CallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start().viewModel.engagementDelegate?(
            .engaged(operatorImageUrl: URL.mock.absoluteString)
        )

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .engaged(let operatorImageUrl):
            XCTAssertEqual(URL.mock.absoluteString, operatorImageUrl)
        default: XCTFail()
        }
    }

    func test_engagementDelegateFinished() throws {
        var calledEvents: [CallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.start().viewModel.engagementDelegate?(.finished)

        XCTAssertEqual(calledEvents.count, 1)
        switch try XCTUnwrap(calledEvents.first) {
        case .finished: XCTAssertTrue(true)
        default: XCTFail()
        }
    }
}
