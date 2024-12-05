@testable import GliaWidgets
import XCTest

final class SecureConversationsChatWithTranscriptModelTests: XCTestCase {
    typealias Model = SecureConversations.ChatWithTranscriptModel

    func testMarkMessageAsFailed() {
        let itemIndex = 1
        let sectionIndex = 3
        let errorMessage = "Failed"
        let section = Section<ChatItem>(sectionIndex)
        let outgoingMessage = OutgoingMessage(payload: .mock())
        let item = ChatItem(with: outgoingMessage)
        
        section.append(ChatItem(kind: .operatorMessage(.mock(), showsImage: false, imageUrl: nil)))
        section.append(item)
        section.append(ChatItem(kind: .operatorMessage(.mock(), showsImage: false, imageUrl: nil)))

        Model.markMessageAsFailed(
            outgoingMessage,
            in: section,
            message: errorMessage
        ) { action in
            switch action {
            case let .refreshRows(rows, section, _):
                XCTAssertEqual(rows, [itemIndex])
                XCTAssertEqual(section, sectionIndex)
            default:
                XCTFail("action should be `refreshRows`")
            }
        }

        switch section.items[itemIndex].kind {
        case let .outgoingMessage(message, error):
            XCTAssertEqual(message.payload.messageId, message.payload.messageId)
            XCTAssertEqual(error, errorMessage)
        default:
            XCTFail("Message kind should be `outgoingMessage`")
        }
    }

    func testRemoveMessage() {
        let itemIndex = 1
        let sectionIndex = 3
        let section = Section<ChatItem>(sectionIndex)
        let outgoingMessage = OutgoingMessage(payload: .mock())
        let item = ChatItem(with: outgoingMessage)

        section.append(ChatItem(kind: .operatorMessage(.mock(), showsImage: false, imageUrl: nil)))
        section.append(item)
        section.append(ChatItem(kind: .operatorMessage(.mock(), showsImage: false, imageUrl: nil)))

        XCTAssertEqual(section.itemCount, 3)

        Model.removeMessage(
            outgoingMessage,
            in: section
        ) { action in
            switch action {
            case let .deleteRows(rows, section, _):
                XCTAssertEqual(rows, [itemIndex])
                XCTAssertEqual(section, sectionIndex)
            default:
                XCTFail("action should be `deleteRows`")
            }
        }

        let contains = section.items.contains(where: { $0.kind == item.kind })

        XCTAssertEqual(contains, false)
        XCTAssertEqual(section.itemCount, 2)
    }
    
    func testEntryWidget() {
        let chatViewModel = Model.chat(.mock())
        let transcriptViewModel = Model.transcript(
            .mock(
                availability: .mock,
                deliveredStatusText: "Delivered",
                failedToDeliverStatusText: "Failed to deliver",
                interactor: .mock()
            )
        )
    
        XCTAssertNil(chatViewModel.entryWidget)
        XCTAssertNotNil(transcriptViewModel.entryWidget)
    }

    func test_isSendMessageAvailableReturnsTrueForChatViewModel() {
        let chatViewModel = Model.chat(.mock())
        XCTAssertTrue(chatViewModel.isSendMessageAvailable)
    }
}
