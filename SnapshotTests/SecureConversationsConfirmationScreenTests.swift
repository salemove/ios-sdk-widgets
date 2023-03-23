import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class SecureConversationsConfirmationScreenTests: SnapshotTestCase {
    let theme = Theme.mock()

    func test_confirmationView() {
        let props = Self.makeConfirmationProps(style: theme.secureConversationsConfirmation)
        let viewController = SecureConversations.ConfirmationViewController(
            viewModel: .init(environment: .init(confirmationStyle: theme.defaultSecureConversationsConfirmationStyle)),
            viewFactory: .mock(theme: theme, messageRenderer: nil, environment: .mock),
            props: props
        )
        viewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: viewController.view,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: self.nameForDevice()
        )
    }

    // MARK: - Helpers

    static func headerProps() -> Header.Props {
        .mock(
            title: "Secure Conversations",
            backButton: .init(style: .mock(image: Asset.back.image)),
            closeButton: .init(style: .mock(image: Asset.close.image))
        )
    }

    static func makeConfirmationProps(
        headerProps: Header.Props = headerProps(),
        style: SecureConversations.ConfirmationStyle
    ) -> SecureConversations.ConfirmationViewController.Props {
        .init(
            confirmationViewProps: .init(
                style: style,
                header: headerProps,
                checkMessageButtonTap: .nop
            )
        )
    }
}
