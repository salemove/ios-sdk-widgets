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
        alert.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        alert.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_mediaUpgradeOffer_extra3Large() {
        let alert = alert(ofKind: .singleMediaUpgrade(
            .mock(),
            accepted: {},
            declined: {}
        ))
        alert.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        alert.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_messageAlert_extra3Large() {
        let alert = alert(ofKind: .message(
            conf: .mock(),
            accessibilityIdentifier: nil,
            dismissed: {}
        ))
        alert.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        alert.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_singleAction_extra3Large() {
        let alert = alert(ofKind: .singleAction(
            conf: .mock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            actionTapped: {}
        ))
        alert.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        alert.assertSnapshot(as: .extra3LargeFont, in: .landscape)
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
        alert.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        alert.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_liveObservationConfirmationAlertWithLinks() {
        let alert = alert(ofKind: .liveObservationConfirmation(
            .liveObservationWithLinksMock(),
            link: { _ in },
            accepted: {},
            declined: {}
        ))

        alert.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        alert.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_leaveCurrentConversationAlert() {
        let alert = alert(ofKind: .leaveConversation(
            conf: .leaveConversationMock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            confirmed: {},
            declined: {}
        ))

        alert.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        alert.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
