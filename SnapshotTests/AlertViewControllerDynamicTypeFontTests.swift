import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class AlertViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func test_screenSharingOffer_extra3Large() {
        let alert = alert(ofKind: .screenShareOffer(
            .mock(),
            accepted: {},
            declined: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_mediaUpgradeOffer_extra3Large() {
        let alert = alert(ofKind: .singleMediaUpgrade(
            .mock(),
            accepted: {},
            declined: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_messageAlert_extra3Large() {
        let alert = alert(ofKind: .message(
            .mock(),
            accessibilityIdentifier: nil,
            dismissed: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_singleAction_extra3Large() {
        let alert = alert(ofKind: .singleAction(
            .mock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            actionTapped: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }

    private func alert(ofKind kind: AlertViewController.Kind) -> AlertViewController {
        let viewController = AlertViewController(
            kind: kind,
            viewFactory: .mock()
        )
        viewController.view.frame = UIScreen.main.bounds
        return viewController
    }
}
