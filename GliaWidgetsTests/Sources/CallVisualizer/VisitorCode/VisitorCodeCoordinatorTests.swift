import Foundation
import XCTest
@testable import GliaWidgets

final class VisitorCodeCoordinatorTests: XCTestCase {
    var coordinator: CallVisualizer.VisitorCodeCoordinator!
    var viewController: UIViewController!

    override func setUp() {
        viewController = UIViewController()

        createCoordinator(withPresentation: .alert(viewController))
    }

    override func tearDown() {
        viewController = nil
        coordinator = nil
    }

    func createCoordinator(
        withPresentation presentation: CallVisualizer.Presentation
    )  {
        let environmentMock = CallVisualizer.VisitorCodeCoordinator.Environment(
            timerProviding: .mock,
            requestVisitorCode: { try .mock() }
        )

        coordinator = CallVisualizer.VisitorCodeCoordinator(
            theme: .mock(),
            environment: environmentMock,
            presentation: presentation
        )
    }

    @MainActor
    func test_startWithAlertPresentation() async throws {
        XCTAssertNil(coordinator.codeViewController)

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        let codeController = await coordinator.start()
        XCTAssertEqual(viewController.presentedViewController, codeController)
        XCTAssertNotNil(coordinator.codeViewController)
    }

    @MainActor
    func test_startWithViewPresentation() async throws {
        XCTAssertNil(coordinator.codeViewController)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        viewController.view.frame = oldRootViewController!.view.frame
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        createCoordinator(
            withPresentation: .embedded(
                viewController.view, 
                onEngagementAccepted: {}
            )
        )

        let coordinatorViewController = await coordinator.start()
        let visitorCodeView = viewController.view.subviews.first

        XCTAssertEqual(visitorCodeView, coordinatorViewController.view)
        XCTAssertNotNil(coordinator.codeViewController)
    }

    // Delegate

    @MainActor
    func test_delegatePropsUpdated() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }
        _ = await coordinator.start()
        
        let newProps = CallVisualizer.VisitorCodeView.Props(
            viewState: .error(refreshTap: .nop)
        )
        coordinator.viewModel?.delegate(
            .propsUpdated(.init(visitorCodeViewProps: newProps))
        )
        
        switch coordinator.codeViewController?.props.visitorCodeViewProps.viewState {
        case .error:
            XCTAssertTrue(true)
        default: XCTFail()
        }
    }

    @MainActor
    func test_delegateCloseButtonTap() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        var calledEvents: [CallVisualizer.VisitorCodeCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        _ = await coordinator.start()
        coordinator.viewModel?.delegate(.closeButtonTap)

        XCTAssertTrue(calledEvents.contains(.closeTapped))
    }
}
