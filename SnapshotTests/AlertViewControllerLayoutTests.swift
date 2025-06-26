@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class AlertViewControllerLayoutTests: SnapshotTestCase {
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
            conf: .mock(),
            accessibilityIdentifier: nil,
            dismissed: {}
        ))
        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    func test_singleAction() {
        let alert = alert(ofKind: .singleAction(
            conf: .mock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            actionTapped: {}
        ))
        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    private func alert(ofKind type: AlertType) -> AlertViewController {
        let viewController = AlertViewController(
            type: type,
            viewFactory: .mock()
        )
        return viewController
    }

    func test_liveObservationConfirmationAlert() {
        let alert = alert(ofKind: .liveObservationConfirmation(
            .liveObservationMock(),
            link: { _ in },
            accepted: {},
            declined: {}
        ))

        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    func test_liveObservationConfirmationAlertWithLinks() {
        let alert = alert(ofKind: .liveObservationConfirmation(
            .liveObservationWithLinksMock(),
            link: { _ in },
            accepted: {},
            declined: {}
        ))

        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }

    func test_leaveCurrentConversationAlert() {
        let alert = alert(ofKind: .leaveConversation(
            conf: .leaveConversationMock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            confirmed: {},
            declined: {}
        ))

        alert.assertSnapshot(as: .image, in: .portrait)
        alert.assertSnapshot(as: .image, in: .landscape)
    }
}
