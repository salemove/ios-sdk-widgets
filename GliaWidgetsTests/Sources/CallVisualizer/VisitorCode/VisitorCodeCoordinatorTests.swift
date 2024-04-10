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

    func createCoordinator(
        withPresentation presentation: CallVisualizer.Presentation
    )  {
        let environmentMock = CallVisualizer.VisitorCodeCoordinator.Environment(
            timerProviding: .mock
        ) { completion in
            return .mock
        }

        coordinator = CallVisualizer.VisitorCodeCoordinator(
            theme: .mock(),
            environment: environmentMock,
            presentation: presentation
        )
    }

    func test_startWithAlertPresentation() throws {
        XCTAssertNil(coordinator.codeViewController)

        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        let codeController = coordinator.start()
        XCTAssertEqual(viewController.presentedViewController, codeController)
        XCTAssertNotNil(coordinator.codeViewController)
    }

    func test_startWithViewPresentation() throws {
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

        let coordinatorViewController = coordinator.start()
        let visitorCodeView = viewController.view.subviews.first

        XCTAssertEqual(visitorCodeView, coordinatorViewController.view)
        XCTAssertNotNil(coordinator.codeViewController)
    }

    // Delegate

    func test_delegatePropsUpdated() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        _ = coordinator.start()
        switch coordinator.codeViewController?.props.visitorCodeViewProps.viewState {
        case .loading:
            XCTAssertTrue(true)
        default: XCTFail()
        }

        let newProps = CallVisualizer.VisitorCodeView.Props(
            viewState: .success(visitorCode: "12345")
        )

        coordinator.viewModel?.delegate(
            .propsUpdated(.init(visitorCodeViewProps: newProps))
        )
        
        switch coordinator.codeViewController?.props.visitorCodeViewProps.viewState {
        case .success(let visitorCode):
            XCTAssertEqual(visitorCode, "12345")
        default: XCTFail()
        }
    }

    func test_delegateCloseButtonTap() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = scene.windows.first
        let oldRootViewController = window?.rootViewController
        window?.rootViewController = viewController
        defer { window?.rootViewController = oldRootViewController }

        var calledEvents: [CallVisualizer.VisitorCodeCoordinator.DelegateEvent] = []
        coordinator.delegate = { event in
            calledEvents.append(event)
        }

        _ = coordinator.start()
        coordinator.viewModel?.delegate(.closeButtonTap)

        XCTAssertTrue(calledEvents.contains(.closeTap))
    }
}
