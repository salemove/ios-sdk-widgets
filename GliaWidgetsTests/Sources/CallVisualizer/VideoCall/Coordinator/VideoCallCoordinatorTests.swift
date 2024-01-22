import Foundation
import XCTest
@testable import GliaWidgets

final class VideoCallCoordinatorTests: XCTestCase {
    var coordinator: CallVisualizer.VideoCallCoordinator!

    override func setUp() {
        coordinator = CallVisualizer.VideoCallCoordinator(
            environment: .mock,
            theme: .mock(),
            call: .mock()
        )
    }

    func test_startGeneratesVideoCallViewController() {
        let viewController = coordinator.start() as? CallVisualizer.VideoCallViewController

        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator.viewController)
    }

    func test_resume() {
        _ = coordinator.start()
        let viewController = coordinator.resume() as? CallVisualizer.VideoCallViewController

        XCTAssertNotNil(viewController)
    }

    func test_resumeCreatesNewViewController() {
        let viewController = coordinator.resume() as? CallVisualizer.VideoCallViewController

        XCTAssertNotNil(viewController)
        XCTAssertNotNil(coordinator.viewController)
    }

    // Show delegate

    func test_showDelegatePropsUpdated() {
        let viewController = coordinator.start() as? CallVisualizer.VideoCallViewController

        let props: CallVisualizer.VideoCallViewController.Props = .init(
            videoCallViewProps: .mock(),
            viewDidLoad: .nop
        )

        let event: CallVisualizer.VideoCallViewModel.DelegateEvent = .propsUpdated(props)

        coordinator.viewModel?.delegate?(event)

        XCTAssertEqual(viewController?.props, props)
    }

    func test_showDelegateMinimize() throws {
        _ = coordinator.start()

        var calledEvents: [CallVisualizer.VideoCallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.viewModel?.delegate?(.minimized)

        XCTAssertEqual(calledEvents.count, 1)
        XCTAssertEqual(try XCTUnwrap(calledEvents.first), .close)
    }

    // Resume delegate

    func test_resumeDelegatePropsUpdated() {
        _ = coordinator.start()
        let viewController = coordinator.resume() as? CallVisualizer.VideoCallViewController

        let props: CallVisualizer.VideoCallViewController.Props = .init(
            videoCallViewProps: .mock(),
            viewDidLoad: .nop
        )

        let event: CallVisualizer.VideoCallViewModel.DelegateEvent = .propsUpdated(props)

        coordinator.viewModel?.delegate?(event)

        XCTAssertEqual(viewController?.props, props)
    }

    func test_resumeDelegateMinimize() throws {
        _ = coordinator.start()
        _ = coordinator.resume()

        var calledEvents: [CallVisualizer.VideoCallCoordinator.DelegateEvent] = []

        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        coordinator.viewModel?.delegate?(.minimized)

        XCTAssertEqual(calledEvents.count, 1)
        XCTAssertEqual(try XCTUnwrap(calledEvents.first), .close)
    }
}
