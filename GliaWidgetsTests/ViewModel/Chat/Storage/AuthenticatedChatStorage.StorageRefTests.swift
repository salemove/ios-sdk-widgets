@testable import GliaWidgets
import XCTest

class AuthenticatedChatStorageStorageRefTests: XCTestCase {
    var ref = AuthenticatedChatStorage.StorageRef()

    override func setUp() {
        ref = .init()
    }

    func test_storeMessagePlacesMessageId() {
        let queueId = "queueID"
        let messageId = "messageId"
        let message = ChatMessage(
            id: messageId,
            queueID: queueId,
            operator: .mock(),
            sender: .operator,
            content: "content",
            attachment: nil,
            downloads: []
        )
        ref.storeMessage(
            message,
            for: queueId
        )
        XCTAssertEqual(ref.messageIdsForQueue, [queueId: [messageId]])
    }

    func test_messagesForQueueReturnsMessages() {
        let queueId = "queueID"
        let messageId = "messageId"
        let message = ChatMessage(
            id: messageId,
            queueID: queueId,
            operator: .mock(),
            sender: .operator,
            content: "content",
            attachment: nil,
            downloads: []
        )
        ref.storeMessage(
            message,
            for: queueId
        )
        XCTAssertEqual(ref.messagesForQueue(queueId).map(\.id), [message.id])
    }

    func test_updateMessageReplacesMessage() {
        let queueId = "queueID"
        let messageId = "messageId"
        let message = ChatMessage(
            id: messageId,
            queueID: queueId,
            operator: .mock(),
            sender: .operator,
            content: "content",
            attachment: nil,
            downloads: []
        )
        ref.storeMessage(
            message,
            for: queueId
        )

        let otherContent = "otherContent"
        let newMessage = ChatMessage(
            id: messageId,
            queueID: queueId,
            operator: .mock(),
            sender: .operator,
            content: otherContent,
            attachment: nil,
            downloads: []
        )

        ref.updateMessage(newMessage)

        XCTAssertEqual(ref.messageForMessageId[message.id]?.content, otherContent)
    }

    func test_isNewMessageReturnsTrueForNotStoredMessage() {
        let messageId = "messageId"
        XCTAssertTrue(ref.isNewMessage(messageId))
    }

    func test_isNewMessageReturnsFalseForStoredMessage() {
        let messageId = "messageId"
        let queueId = "queueID"
        let message = ChatMessage(
            id: messageId,
            queueID: queueId,
            operator: .mock(),
            sender: .operator,
            content: "content",
            attachment: nil,
            downloads: []
        )
        ref.storeMessage(
            message,
            for: queueId
        )
        XCTAssertFalse(ref.isNewMessage(messageId))
    }
}
