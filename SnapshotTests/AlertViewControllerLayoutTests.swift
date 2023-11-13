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
        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    func test_mediaUpgradeOffer() {
        let alert = alert(ofKind: .singleMediaUpgrade(
            .mock(),
            accepted: {},
            declined: {}
        ))
        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    func test_messageAlert() {
        let alert = alert(ofKind: .message(
            .mock(),
            accessibilityIdentifier: nil,
            dismissed: {}
        ))
        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    func test_singleAction() {
        let alert = alert(ofKind: .singleAction(
            .mock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            actionTapped: {}
        ))
        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    private func alert(ofKind kind: AlertViewController.Kind) -> AlertViewController {
        let viewController = AlertViewController(
            kind: kind,
            viewFactory: .mock()
        )
        return viewController
    }

    func test_liveObservationConfirmationAlert() {
        let alert = alert(ofKind: .liveObservationConfirmation(
            .liveObservationMock(),
            accepted: {},
            declined: {}
        ))
        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }
}
