import XCTest
@testable import GliaWidgets

final class ChatViewTest: XCTestCase {

    var view: ChatView!

    func test_contentForChatItemIsChoiceCardIfThereIsBrokenMetadata() throws {
        let env = EngagementView.Environment(
            data: .failing,
            uuid: { .mock },
            gcd: .failing,
            imageViewCache: .failing,
            timerProviding: .failing,
            uiApplication: .failing,
            uiScreen: .failing
        )
        view = ChatView(
            with: .mock(),
            messageRenderer: .webRenderer,
            environment: env,
            props: .init(header: .mock())
        )
        let metadataDecodingContainer = try CoreSdkMessageMetadataContainer(
            jsonData: "{ }".data(using: .utf8)!
        ).container
        let message = ChatMessage.mock(
            sender: .operator,
            attachment: ChatAttachment.mock(
                type: .singleChoice,
                files: nil,
                imageUrl: nil,
                options: nil
            ),
            metadata: MessageMetadata(container: metadataDecodingContainer)
        )
        let item = try XCTUnwrap(ChatItem(
            with: message,
            isCustomCardSupported: true
        ))
        switch view.content(for: item) {
        case .choiceCard:
            break
        default:
            XCTFail("Content should be .choiceCard")
        }
    }
}
