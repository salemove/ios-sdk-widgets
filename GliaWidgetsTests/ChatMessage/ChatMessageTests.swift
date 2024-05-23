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

    func testCardType__metadataWithoutSingleChoice() throws {
        let metadataDecodingContainer = try CoreSdkMessageMetadataContainer(
            jsonData: "{\"html\": \"Hello\"}".data(using: .utf8)!
        ).container
        let msg = ChatMessage.mock(
            attachment: .mock(type: nil, files: nil, imageUrl: nil, options: nil),
            metadata: MessageMetadata(container: metadataDecodingContainer)
        )
        XCTAssertEqual(msg.cardType, .customCard)
    }
}
