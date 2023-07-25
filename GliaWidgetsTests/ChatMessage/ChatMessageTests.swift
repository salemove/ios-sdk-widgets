import GliaCoreSDK
import XCTest

@testable import GliaWidgets

final class ChatMessageTests: XCTestCase {

    func testCardType__singleChoiceWithoutMetadata() throws {
        let msg = ChatMessage.mock(
            attachment: .mock(type: .singleChoice, files: nil, imageUrl: nil, options: nil),
            metadata: nil
        )
        XCTAssertEqual(msg.cardType, .choiceCard)
    }

    func testCardType__singleChoiceWithMetadata() throws {
        let metadataDecodingContainer = try CoreSdkMessageMetadataContainer(
            jsonData: "{\"html\": \"Hello\"}".data(using: .utf8)!
        ).container
        let msg = ChatMessage.mock(
            attachment: .mock(type: .singleChoice, files: nil, imageUrl: nil, options: nil),
            metadata: MessageMetadata(container: metadataDecodingContainer)
        )
        XCTAssertEqual(msg.cardType, .customCard)
    }
}

extension ChatMessage {
    static func mock(
        id: String = "mocked-message-id",
        queueId: String? = "queue-id",
        operator: ChatOperator? = .init(name: "XCTest Operator", pictureUrl: nil),
        sender: ChatMessageSender = .`operator`,
        content: String = "Hello unit test!",
        attachment: ChatAttachment? = nil,
        downloads: [FileDownload] = [],
        metadata: MessageMetadata? = nil
    ) -> ChatMessage {
        ChatMessage(
            id: id,
            queueID: queueId,
            operator: `operator`,
            sender: sender,
            content: content,
            attachment: attachment,
            downloads: downloads,
            metadata: metadata
        )
    }
}
