import XCTest
import UIKit
@testable import GliaWidgets

final class AlertViewControllerTests: XCTestCase {
    @MainActor
    func test_confirmationCloseInvokesDismissedCallback() async throws {
        var dismissed = false
        var closed = false
        let controller = ImmediateDismissAlertViewController(
            type: .confirmation(
                conf: .mock(),
                accessibilityIdentifier: "confirmation",
                confirmed: {},
                onClose: { closed = true },
                dismissed: { dismissed = true }
            ),
            viewFactory: .mock()
        )
        controller.loadViewIfNeeded()
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()
        let alert = try XCTUnwrap(controller.view.subviews.compactMap { $0 as? AlertView }.first)

        await alert.closeTapped?()

        XCTAssertTrue(dismissed)
        XCTAssertFalse(closed)
    }

    @MainActor
    func test_confirmationActionWaitsForDismissalCompletion() async throws {
        var confirmed = false
        let controller = DeferredDismissAlertViewController(type: .confirmation(
            conf: .mock(), accessibilityIdentifier: "confirmation", confirmed: {}, onClose: {}, dismissed: nil
        ), viewFactory: .mock())
        let alert = controller.makeConfirmationAlertView(
            with: .mock(), accessibilityIdentifier: "confirmation",
            confirmed: { confirmed = true }, dismissed: nil
        )
        alert.setNeedsUpdateConstraints()
        alert.updateConstraintsIfNeeded()
        let button = try XCTUnwrap(actionButtons(in: alert).first {
            $0.props.accessibilityIdentifier == "alert_positive_button"
        })
        guard case let .async(command) = button.props.tap else { return XCTFail("Expected async action") }
        let task = Task { await command() }
        await waitUntil { controller.dismissalCompletion != nil }
        XCTAssertFalse(confirmed)

        controller.dismissalCompletion?()
        await task.value
        XCTAssertTrue(confirmed)
    }

    @MainActor
    func test_liveObservationActionsWaitForDismissalCompletion() async throws {
        for title in ["Cancel", "Allow"] {
            var accepted = false
            var declined = false
            let controller = DeferredDismissAlertViewController(type: .confirmation(
                conf: .mock(), accessibilityIdentifier: "confirmation", confirmed: {}, onClose: {}, dismissed: nil
            ), viewFactory: .mock())
            let alert = controller.makeLiveObservationAlertView(
                with: .liveObservationMock(), link1: { _ in }, link2: { _ in },
                accepted: { accepted = true }, declined: { declined = true }
            )
            alert.setNeedsUpdateConstraints()
            alert.updateConstraintsIfNeeded()
            let button = try XCTUnwrap(actionButtons(in: alert).first { $0.props.style.title == title })
            guard case let .async(command) = button.props.tap else { return XCTFail("Expected async action") }
            let task = Task { await command() }
            await waitUntil { controller.dismissalCompletion != nil }
            XCTAssertFalse(accepted)
            XCTAssertFalse(declined)

            controller.dismissalCompletion?()
            await task.value
            XCTAssertEqual(accepted, title == "Allow")
            XCTAssertEqual(declined, title == "Cancel")
        }
    }

    @MainActor
    private func actionButtons(in view: UIView) -> [ActionButton] {
        if let button = view as? ActionButton { return [button] }
        return view.subviews.flatMap { actionButtons(in: $0) }
    }

    func test_isSingleActionReplaceable() {
        /// `lhs` is a `AlertKind` which we want to test whether it can be replaced
        /// `rhs` is an array of tuples which contains `AlertKind` to compare with `lhs` and
        /// a `Bool` value is indicating whether lhs `AlertKind` can be replaced with rhs `AlertKind`
        let data: [(lhs: AlertKind, rhs: [(AlertKind, Bool)])] = [
            (.message, [(.message, true),
                        (.singleAction, true),
                        (.singleMediaUpgrade, true),
                        (.confirmation, true)]),
            (.singleAction, [(.message, false),
                             (.singleAction, true),
                             (.singleMediaUpgrade, true),
                             (.confirmation, false)]),
            (.singleMediaUpgrade, [(.message, false),
                                   (.singleAction, true),
                                   (.singleMediaUpgrade, true),
                                   (.confirmation, false)]),
            (.confirmation, [(.message, false),
                             (.singleAction, true),
                             (.singleMediaUpgrade, true),
                             (.confirmation, true)])
        ]

        func test(
            replaceable: Replaceable,
            data: (kind: AlertKind, isReplaceable: Bool)
        ) {
            let alert = AlertViewController.mock(type: AlertKind.mock(type: data.kind))
            XCTAssertEqual(replaceable.isReplaceable(with: alert), data.isReplaceable)
        }

        data.forEach { item in
            let alert = AlertViewController.mock(type: AlertKind.mock(type: item.lhs))
            item.rhs.forEach {
                test(replaceable: alert, data: $0)
            }
        }
    }
}

private final class ImmediateDismissAlertViewController: AlertViewController {
    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        completion?()
    }
}

private final class DeferredDismissAlertViewController: AlertViewController {
    var dismissalCompletion: (() -> Void)?

    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        dismissalCompletion = completion
    }
}
