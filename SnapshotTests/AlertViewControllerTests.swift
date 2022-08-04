import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class AlertViewControllerTests: SnapshotTestCase {
    func test_screenSharingOffer() {
        let alert = alert(ofKind: .screenShareOffer(
            .mock(),
            accepted: {},
            declined: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_mediaUpgradeOffer() {
        let alert = alert(ofKind: .singleMediaUpgrade(
            .mock(),
            accepted: {},
            declined: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_messageAlert() {
        let alert = alert(ofKind: .message(
            .mock(),
            accessibilityIdentifier: nil,
            dismissed: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_singleAction() {
        let alert = alert(ofKind: .singleAction(
            .mock(),
            actionTapped: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }

    private func alert(ofKind kind: AlertViewController.Kind) -> AlertViewController {
        AlertViewController(
            kind: kind,
            viewFactory: .mock()
        )
    }
}
