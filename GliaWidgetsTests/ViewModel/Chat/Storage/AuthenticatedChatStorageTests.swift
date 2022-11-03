@testable import GliaWidgets
import XCTest

class AuthenticatedChatStorageTests: XCTestCase {
    var storage = AuthenticatedChatStorage.inMemory(.init())

    override func setUp() {
        storage = AuthenticatedChatStorage.inMemory(.init())
    }

    func test_storeMessagePlacesMessageId() {
        let ref = AuthenticatedChatStorage.StorageRef()
        let queueId = "queueID"
        let messageId = "messageId"
        let message = CoreSdkClient.Message.mock(id: messageId)
        storage = .inMemory(ref)
        storage.storeMessage(message, queueId, .mock())
        XCTAssertEqual(ref.messages.map(\.id), [message.id])

    }

    func test_messagesReturnsMessagesForQueueId() {
        let queueId = "queueID"
        let messageId = "messageId"
        let message = CoreSdkClient.Message.mock(id: messageId)
        storage.storeMessage(message, queueId, .mock())
        XCTAssertEqual(storage.messages(queueId).map(\.id), [message.id])
    }

    func test_updateMessageReplacesMessage() {
        let queueId = "queueID"
        let messageId = "messageId"
        let message = CoreSdkClient.Message.mock(id: messageId)
        storage.storeMessage(
            message,
            queueId,
            .mock()
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

        storage.updateMessage(newMessage)

        XCTAssertEqual(storage.messages(queueId).map(\.content), [otherContent])
    }

    func test_isNewMessageReturnsTrueForNotStoredMessage() {
        let messageId = "messageId"
        XCTAssertTrue(storage.isNewMessage(.mock(id: messageId)))
    }

    func test_isNewMessageReturnsFalseForStoredMessage() {
        let messageId = "messageId"
        let queueId = "queueID"
        let message = CoreSdkClient.Message.mock(id: messageId)
        storage.storeMessage(
            message,
            queueId,
            .mock()
        )
        XCTAssertFalse(storage.isNewMessage(message))
    }
}
