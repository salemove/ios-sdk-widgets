@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class AlertViewControllerLayoutTests: SnapshotTestCase {
    func test_screenSharingOffer() {
        let alert = alert(ofKind: .screenShareOffer(
            .mock(),
            accepted: {},
            declined: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .image,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .imageLandscape,
            named: nameForDevice(.landscape)
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
            as: .image,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .imageLandscape,
            named: nameForDevice(.landscape)
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
            as: .image,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .imageLandscape,
            named: nameForDevice(.landscape)
        )
    }

    func test_singleAction() {
        let alert = alert(ofKind: .singleAction(
            .mock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            actionTapped: {}
        ))
        assertSnapshot(
            matching: alert,
            as: .image,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: alert,
            as: .imageLandscape,
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
