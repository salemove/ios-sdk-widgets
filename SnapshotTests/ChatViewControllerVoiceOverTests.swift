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
        assertSnapshot(matching: viewController, as: .accessibilityImage, named: nameForDevice())
    }

    func test_choiceCard() throws {
        let viewController = try ChatViewController.mockChoiceCard()
        assertSnapshot(matching: viewController, as: .accessibilityImage, named: nameForDevice())
    }
}
