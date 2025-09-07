@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ChatViewControllerDynamicTypeFontTests: SnapshotTestCase {
    @MainActor
    func test_messagesFromHistory_extra3Large() async {
        let viewController = await ChatViewController.mockHistoryMessagesScreen()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_visitorUploadedFileStates_extra3Large() async throws {
        let viewController = try await ChatViewController.mockVisitorFileUploadStates()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_choiceCard_extra3Large() async throws {
        let viewController = try await ChatViewController.mockChoiceCard()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    @MainActor
    func test_visitorFileDownloadStates_extra3Large() async throws {
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
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_secureMessagingBottomAndCollapsedTopBanner_extra3Large() {
        let viewController = ChatViewController.mockSecureMessagingBottomBannerView()
        viewController.updateViewConstraints()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
    
    func test_secureMessagingBottomAndExpandedTopBanner_extra3Large() {
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
            viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
            viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
        }
    }
}
