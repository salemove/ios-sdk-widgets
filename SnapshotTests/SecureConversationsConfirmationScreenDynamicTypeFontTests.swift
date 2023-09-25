@testable import GliaWidgets
import SnapshotTesting
import XCTest

// swiftlint:disable type_name
final class SecureConversationsConfirmationScreenDynamicTypeFontTests: SnapshotTestCase {
    let theme = Theme.mock()

    func test_confirmationView_extra3Large() {
        let model: SecureConversations.ConfirmationViewSwiftUI.Model = .init(
            environment: .init(
                orientationManager: .mock(), uiApplication: .mock
            ),
            style: theme.defaultSecureConversationsConfirmationStyle,
            delegate: nil
        )
        let viewController = SecureConversations.ConfirmationViewController(model: model)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
// swiftlint:enable type_name
