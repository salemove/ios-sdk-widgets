import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ChatViewControllerVoiceOverTests: SnapshotTestCase {
    @MainActor
    func test_messagesFromHistory() async {
        let viewController = await ChatViewController.mockHistoryMessagesScreen()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    @MainActor
    func test_visitorUploadedFileStates() async throws {
        let viewController = try await ChatViewController.mockVisitorFileUploadStates()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    @MainActor
    func test_choiceCard() async throws {
        let viewController = try await ChatViewController.mockChoiceCard()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    @MainActor
    func test_visitorFileDownloadStates() async throws {
        var chatMessages: [ChatMessage] = []
        let viewController = try await ChatViewController.mockVisitorFileDownloadStates { messages in
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

    @MainActor
    func test_gvaPersistentButton() async throws {
        let viewController = try await ChatViewController.mockGvaPersistentButton()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    @MainActor
    func test_gvaResponseText() async throws {
        let viewController = try await ChatViewController.mockGvaResponseText()
        viewController.assertSnapshot(as: .accessibilityImage)
    }

    @MainActor
    func test_gvaGalleryCard() async throws {
        let viewController = try await ChatViewController.mockGvaGalleryCards()
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

    func test_secureMessagingTopAndBottomBanner() {
        let mockEntryWidgetViewState = EntryWidget.ViewState.mediaTypes(
            [.init(type: .chat), .init(type: .video), .init(type: .audio)]
        )
        let viewController = ChatViewController.mockSecureMessagingTopAndBottomBannerView(
            entryWidgetViewState: mockEntryWidgetViewState
        )
        viewController.updateViewConstraints()
        
        (viewController.view as? ChatView)?.setIsTopBannerExpanded(true)
        viewController.updateViewConstraints()
        
        viewController.view.frame = UIScreen.main.bounds
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()

        DispatchQueue.main.async {
            viewController.assertSnapshot(as: .accessibilityImage)
        }
    }
}
