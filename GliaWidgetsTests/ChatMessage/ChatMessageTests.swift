import XCTest
@_spi(GliaWidgets) internal import GliaCoreSDK

@testable import GliaWidgets

final class ChatMessageTests: XCTestCase {
    func testRendererMessagePreservesCoreMetadataAndIdentifier() throws {
        struct Payload: Decodable { let customValue: String }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let metadataContainer = try CoreSdkMessageMetadataContainer(
            jsonData: Data(#"{"metadata":{"custom_value":"render me"}}"#.utf8),
            jsonDecoder: decoder
        ).container
        let metadata = CoreSdkClient.Message.Metadata(container: metadataContainer)
        let chatMessage = ChatMessage(with: CoreSdkClient.Message(
            id: "message-id",
            content: "",
            sender: .init(type: .operator),
            metadata: metadata
        ))
        let message = MessageRenderer.Message(chatMessage: chatMessage)

        XCTAssertEqual(message.id.rawValue, "message-id")
        XCTAssertEqual(try message.metadata?.decode(Payload.self).customValue, "render me")
        XCTAssertNil(message.selectedOption)
    }

    func testRendererIdentifierEncodesAsString() throws {
        let identifier = MessageRenderer.Message.Identifier(rawValue: "message-id")
        let encoded = try JSONEncoder().encode(identifier)
        XCTAssertEqual(String(decoding: encoded, as: UTF8.self), #""message-id""#)
        XCTAssertEqual(try JSONDecoder().decode(MessageRenderer.Message.Identifier.self, from: encoded), identifier)
    }

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
