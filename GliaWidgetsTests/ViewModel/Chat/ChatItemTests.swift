@testable import GliaWidgets
import XCTest

final class ChatItemTests: XCTestCase {
    func testIsOperatorReturnsTrueForExpectedKindCases() {
        let callUpgrade = ChatItem.Kind.mock(kind: .callUpgrade)
        let choiceCard = ChatItem.Kind.mock(kind: .choiceCard)
        let customCard = ChatItem.Kind.mock(kind: .customCard)
        let operatorConnected = ChatItem.Kind.mock(kind: .operatorConnected)
        let queueOperator = ChatItem.Kind.mock(kind: .queueOperator)
        let outgoingMessage = ChatItem.Kind.mock(kind: .outgoingMessage)
        let operatorMessage = ChatItem.Kind.mock(kind: .operatorMessage)
        let systemMessage = ChatItem.Kind.mock(kind: .systemMessage)
        let unreadMessageDivider = ChatItem.Kind.mock(kind: .unreadMessageDivider)
        let visitorMessage = ChatItem.Kind.mock(kind: .visitorMessage)
        let transferring = ChatItem.Kind.mock(kind: .transferring)
        let gvaResponseText = ChatItem.Kind.mock(kind: .gvaResponseText)
        let gvaPersistentButton = ChatItem.Kind.mock(kind: .gvaPersistentButton)
        let gvaQuickReply = ChatItem.Kind.mock(kind: .gvaQuickReply)
        let gvaGallery = ChatItem.Kind.mock(kind: .gvaGallery)
        let kinds: [ChatItem.Kind] = [
            callUpgrade,
            choiceCard,
            customCard,
            operatorConnected,
            queueOperator,
            outgoingMessage,
            operatorMessage,
            systemMessage,
            unreadMessageDivider,
            visitorMessage,
            transferring,
            gvaResponseText,
            gvaPersistentButton,
            gvaQuickReply,
            gvaGallery
        ]
        for kind in kinds {
            let chatItem = ChatItem(kind: kind)
            switch kind {
            case .choiceCard, .customCard, .operatorMessage, .systemMessage:
                XCTAssertTrue(chatItem.isOperatorMessage)
            case .gvaGallery, .gvaQuickReply, .gvaResponseText, .gvaPersistentButton:
                XCTAssertTrue(chatItem.isOperatorMessage)
            case .unreadMessageDivider, .visitorMessage, .transferring,
                 .outgoingMessage, .queueOperator, .operatorConnected, .callUpgrade:
                XCTAssertFalse(chatItem.isOperatorMessage)
            }
        }
    }
}
