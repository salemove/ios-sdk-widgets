import AccessibilitySnapshot
@testable import GliaWidgets
import SnapshotTesting
import XCTest

class ChatViewControllerVoiceOverTests: SnapshotTestCase {
    func test_messagesFromHistory() {
        let viewController = ChatViewController.mockHistoryMessagesScreen()
        viewController.view.frame = UIScreen.main.bounds
        assertSnapshot(matching: viewController, as: .accessibilityImage, named: nameForDevice())
    }

    func test_visitorUploadedFileStates() throws {
        let viewController = try ChatViewController.mockVisitorFileUploadStates()
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: nameForDevice()
        )
    }

    func test_choiceCard() throws {
        let viewController = try ChatViewController.mockChoiceCard()
        assertSnapshot(matching: viewController, as: .accessibilityImage, named: nameForDevice())
    }

    func test_visitorFileDownloadStates() throws {
        var chatMessages: [ChatMessage] = []
        let viewController = try ChatViewController.mockVisitorFileDownloadStates() { messages in
            chatMessages = messages
        }
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(chatMessages.count, 4)
        chatMessages[0].downloads[0].state.value = .none
        chatMessages[1].downloads[0].state.value = .downloading(progress: .init(with: 0.5))
        chatMessages[2].downloads[0].state.value = .downloaded(.mock())
        chatMessages[3].downloads[0].state.value = .error(.deleted)
        assertSnapshot(
            matching: viewController,
            as: .accessibilityImage(precision: SnapshotTestCase.possiblePrecision),
            named: self.nameForDevice()
        )
    }
}
