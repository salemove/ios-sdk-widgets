import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ChatViewControllerVoiceOverTests: SnapshotTestCase {
    func test_messagesFromHistory() {
        let viewController = ChatViewController.mockHistoryMessagesScreen()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_visitorUploadedFileStates() throws {
        let viewController = try ChatViewController.mockVisitorFileUploadStates()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_choiceCard() throws {
        let viewController = try ChatViewController.mockChoiceCard()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_visitorFileDownloadStates() throws {
        var chatMessages: [ChatMessage] = []
        let viewController = try ChatViewController.mockVisitorFileDownloadStates { messages in
            chatMessages = messages
        }
        viewController.view.frame = UIScreen.main.bounds
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(chatMessages.count, 4)
        chatMessages[0].downloads[0].state.value = .none
        chatMessages[1].downloads[0].state.value = .downloading(progress: .init(with: 0.5))
        chatMessages[2].downloads[0].state.value = .downloaded(.mock())
        chatMessages[3].downloads[0].state.value = .error(.deleted)
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_gvaPersistentButton() throws {
        let viewController = try ChatViewController.mockGvaPersistentButton()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_gvaResponseText() throws {
        let viewController = try ChatViewController.mockGvaResponseText()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_gvaGalleryCard() throws {
        let viewController = try ChatViewController.mockGvaGalleryCards()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    func test_gvaQuickReply() throws {
        let theme = Theme()
        let props: QuickReplyView.Props = .shown([
            .init(title: "First Button", action: .nop),
            .init(title: "Second Button", action: .nop),
            .init(title: "Third Button", action: .nop)
        ])
        let view: QuickReplyView = .init(
            style: theme.chat.gliaVirtualAssistant.quickReplyButton,
            props: props
        )
        view.frame = .init(origin: .zero, size: .init(width: 350, height: 200))
        view.collectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.assertSnapshot(as: .accessibilityImage)
    }
}
