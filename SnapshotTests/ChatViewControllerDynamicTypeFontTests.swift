@testable import GliaWidgets
import SnapshotTesting
import XCTest

final class ChatViewControllerDynamicTypeFontTests: SnapshotTestCase {
    func test_messagesFromHistory_extra3Large() {
        let viewController = ChatViewController.mockHistoryMessagesScreen()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_visitorUploadedFileStates_extra3Large() throws {
        let viewController = try ChatViewController.mockVisitorFileUploadStates()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_choiceCard_extra3Large() throws {
        let viewController = try ChatViewController.mockChoiceCard()
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }

    func test_visitorFileDownloadStates_extra3Large() throws {
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
        viewController.assertSnapshot(as: .extra3LargeFont, in: .portrait)
        viewController.assertSnapshot(as: .extra3LargeFont, in: .landscape)
    }
}
