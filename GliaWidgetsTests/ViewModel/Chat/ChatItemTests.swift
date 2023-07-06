@testable import GliaWidgets
import XCTest

final class ChatItemTests: XCTestCase {
    func testIsOperatorReturnsTrueForExpectedKindCases() {
        let callUpgrade = ChatItem.Kind.callUpgrade(.init(with: .audio), duration: .init(with: .zero))
        let choiceCard = ChatItem.Kind.choiceCard(.mock(), showsImage: false, imageUrl: "", isActive: false)
        let customCard = ChatItem.Kind.customCard(.mock(), showsImage: false, imageUrl: nil, isActive: false)
        let operatorConnected = ChatItem.Kind.operatorConnected(name: nil, imageUrl: nil)
        let queueOperator = ChatItem.Kind.queueOperator
        let outgoingMessage = ChatItem.Kind.outgoingMessage(.mock())
        let operatorMessage = ChatItem.Kind.operatorMessage(.mock(), showsImage: false, imageUrl: nil)
        let systemMessage = ChatItem.Kind.systemMessage(.mock())
        let unreadMessageDivider = ChatItem.Kind.unreadMessageDivider
        let visitorMessage = ChatItem.Kind.visitorMessage(.mock(), status: nil)
        let transferring = ChatItem.Kind.transferring
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
            transferring
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


