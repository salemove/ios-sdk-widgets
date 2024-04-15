import Foundation
import XCTest
@testable import GliaWidgets

final class ScreenSharingCoordinatorTests: XCTestCase {
    var coordinator: CallVisualizer.ScreenSharingCoordinator!

    override func setUp() {
        super.setUp()

        let environment = CallVisualizer.ScreenSharingCoordinator.Environment(
            theme: Theme(),
            screenShareHandler: .mock,
            orientationManager: .mock(),
            log: .mock
        )
        coordinator = CallVisualizer.ScreenSharingCoordinator(environment: environment)
    }

    func test_start() {
        let viewController = coordinator.start()

        XCTAssertTrue(viewController is CallVisualizer.ScreenSharingViewController)
    }

    // An attempt to test the view controller dismissal was made but
    // showing/hiding view controller depends a lot on the state of
    // the testing app at that moment, so it was very flaky. Only that
    // the delegate is called is tested.
    func test_delegateCloseTapped() throws {
        let viewController = try XCTUnwrap(
            coordinator.start() as? CallVisualizer.ScreenSharingViewController
        )

        var calledEvents: [CallVisualizer.ScreenSharingCoordinator.DelegateEvent] = []
        self.coordinator.delegate = { event in calledEvents.append(event) }
        viewController.model.delegate(.closeTapped)

        XCTAssertTrue(calledEvents.contains(.close))
    }
}
