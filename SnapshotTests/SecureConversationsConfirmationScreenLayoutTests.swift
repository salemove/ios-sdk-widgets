@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SecureConversationsConfirmationScreenLayoutTests: SnapshotTestCase {
    let theme = Theme.mock()

    func test_confirmationView() {
        let model: SecureConversations.ConfirmationViewSwiftUI.Model = .init(
            environment: .init(
                orientationManager: .mock(), uiApplication: .mock
            ),
            style: theme.defaultSecureConversationsConfirmationStyle,
            delegate: nil
        )
        let viewController = SecureConversations.ConfirmationViewController(model: model)
        viewController.assertSnapshot(as: .image, in: .portrait)
        viewController.assertSnapshot(as: .image, in: .landscape)
    }
}
