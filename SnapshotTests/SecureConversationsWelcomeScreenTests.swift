import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class SecureConversationsWelcomeScreenTests: SnapshotTestCase {
    let theme = Theme.mock()

    func test_welcomeView() {
        let props = Self.makeWelcomeProps(
            theme: theme.secureConversationsWelcome,
            uploads: []
        )
        let viewController = SecureConversations.WelcomeViewController(
            viewFactory: .mock(theme: theme, messageRenderer: nil, environment: .mock),
            props: .welcome(props),
            environment: .init(gcd: .live, uiScreen: .mock, notificationCenter: .mock)
        )
        viewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: viewController.view,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: self.nameForDevice()
        )
    }

    func test_welcomeWithAttachments() {
        let props = Self.makeWelcomeProps(
            theme: theme.secureConversationsWelcome,
            uploads: [
                uploadedFileProps(),
                failedFileUploadProps()
            ]
        )
        let viewController = SecureConversations.WelcomeViewController(
            viewFactory: .mock(theme: theme, messageRenderer: nil, environment: .mock),
            props: .welcome(props),
            environment: .init(gcd: .live, uiScreen: .mock, notificationCenter: .mock)
        )
        viewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: viewController.view,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: self.nameForDevice()
        )
    }

    func test_welcomeViewController_withValidationError() {
        let props = Self.makeWelcomeProps(theme: theme.secureConversationsWelcome, warningMessage: "This is warning message")
        let viewController = SecureConversations.WelcomeViewController(
            viewFactory: .mock(theme: theme, messageRenderer: nil, environment: .mock),
            props: .welcome(props),
            environment: .init(gcd: .live, uiScreen: .mock, notificationCenter: .mock)
        )
        viewController.view.frame = UIScreen.main.bounds

        assertSnapshot(
            matching: viewController.view,
            as: .accessibilityImage(precision: Self.possiblePrecision),
            named: self.nameForDevice()
        )
    }

    // MARK: - Helpers

    func uploadedFileProps() -> SecureConversations.FileUploadView.Props {
        .init(
            id: "id-a",
            style: .messageCenter(theme.secureConversationsWelcome.attachmentListStyle.item),
            state: .uploaded(.init(localFile: .mock())),
            removeTapped: .nop
        )
    }

    func failedFileUploadProps() -> SecureConversations.FileUploadView.Props {
        .init(
            id: "id-b",
            style: .messageCenter(theme.secureConversationsWelcome.attachmentListStyle.item),
            state: .error(.network),
            removeTapped: .nop
        )
    }

    static func headerProps() -> Header.Props {
        .mock(
            title: "Secure Conversations",
            backButton: .init(style: .mock(image: Asset.back.image)),
            closeButton: .init(style: .mock(image: Asset.close.image))
        )
    }

    static func makeWelcomeProps(
        theme: SecureConversations.WelcomeStyle,
        headerProps: Header.Props = headerProps(),
        uploads: [SecureConversations.FileUploadView.Props] = [],
        warningMessage: String = ""
    ) -> SecureConversations.WelcomeView.Props {
        .init(
            style: theme,
            checkMessageButtonTap: .nop,
            filePickerButton: .init(isEnabled: true, tap: .nop),
            sendMessageButton: .active(.nop),
            messageTextViewProps: .active(
                .init(
                    style: theme.messageTextViewStyle,
                    text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                    textChanged: .nop,
                    activeChanged: .nop
                )
            ),
            warningMessage: .init(text: warningMessage, animated: false),
            fileUploadListProps: .init(
                maxUnscrollableViews: 3,
                style: .chat(.mock),
                uploads: .init(uploads),
                isScrollingEnabled: true
            ),
            headerProps: headerProps,
            isUiHidden: false
        )
    }
}
