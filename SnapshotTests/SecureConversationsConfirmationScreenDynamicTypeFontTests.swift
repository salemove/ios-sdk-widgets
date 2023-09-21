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
        viewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: viewController.view,
            as: .extra3LargeFontStrategy,
            named: nameForDevice()
        )
        assertSnapshot(
            matching: viewController.view,
            as: .extra3LargeFontStrategyLandscape,
            named: nameForDevice(.landscape)
        )
    }
}
// swiftlint:enable type_name
