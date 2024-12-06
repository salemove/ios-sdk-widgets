import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class AlertViewControllerVoiceOverTests: SnapshotTestCase {
    func test_screenSharingOffer() {
        let alert = alert(ofKind: .screenShareOffer(
            .mock(),
            accepted: {},
            declined: {}
        ))
        alert.assertSnapshot(as: .accessibilityImage)
    }

    func test_mediaUpgradeOffer() {
        let alert = alert(ofKind: .singleMediaUpgrade(
            .mock(),
            accepted: {},
            declined: {}
        ))
        alert.assertSnapshot(as: .accessibilityImage)
    }

    func test_messageAlert() {
        let alert = alert(ofKind: .message(
            conf: .mock(),
            accessibilityIdentifier: nil,
            dismissed: {}
        ))
        alert.assertSnapshot(as: .accessibilityImage)
    }

    func test_singleAction() {
        let alert = alert(ofKind: .singleAction(
            conf: .mock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            actionTapped: {}
        ))
        alert.assertSnapshot(as: .accessibilityImage)
    }

    func test_liveObservationConfirmationAlert() {
        let alert = alert(ofKind: .liveObservationConfirmation(
            .liveObservationMock(),
            link: { _ in },
            accepted: {},
            declined: {}
        ))
        alert.assertSnapshot(as: .accessibilityImage)
    }

    func test_liveObservationConfirmationAlertWithLinks() {
        let alert = alert(ofKind: .liveObservationConfirmation(
            .liveObservationWithLinksMock(),
            link: { _ in },
            accepted: {},
            declined: {}
        ))

        alert.assertSnapshot(as: .accessibilityImage)
    }

    func test_leaveCurrentConversationAlert() {
        let alert = alert(ofKind: .leaveConversation(
            conf: .leaveConversationMock(),
            accessibilityIdentifier: "mocked-accessibility-identifier",
            confirmed: {},
            declined: {}
        ))

        alert.assertSnapshot(as: .accessibilityImage)
    }

    private func alert(ofKind type: AlertType) -> AlertViewController {
        let viewController = AlertViewController(
            type: type,
            viewFactory: .mock()
        )
        return viewController
    }
}
