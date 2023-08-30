@testable import GliaWidgets
import Foundation

extension ChatItem.Kind {
    enum Internal {
        case queueOperator, outgoingMessage, visitorMessage, operatorMessage,
             choiceCard, customCard, callUpgrade, operatorConnected,
             transferring, unreadMessageDivider, systemMessage,
             gvaPersistentButton, gvaResponseText, gvaQuickReply, gvaGallery
    }
}

extension ChatItem.Kind {
    static func mock(kind: Internal) -> ChatItem.Kind {
        switch kind {
        case .queueOperator: return .queueOperator
        case .outgoingMessage: return .outgoingMessage(.mock())
        case .visitorMessage: return .visitorMessage(.mock(), status: nil)
        case .operatorMessage:
            return .operatorMessage(
                .mock(),
                showsImage: false,
                imageUrl: nil
            )
        case .choiceCard:
            return .choiceCard(
                .mock(),
                showsImage: false,
                imageUrl: nil,
                isActive: false
            )
        case .customCard:
            return .customCard(
                .mock(),
                showsImage: false,
                imageUrl: nil,
                isActive: false
            )
        case .callUpgrade:
            return .callUpgrade(
                .init(with: .audio),
                duration: .init(with: .zero)
            )
        case .operatorConnected: return .operatorConnected(name: nil, imageUrl: nil)
        case .transferring: return .transferring
        case .unreadMessageDivider: return .unreadMessageDivider
        case .systemMessage: return .systemMessage(.mock())
        case .gvaResponseText:
            return .gvaResponseText(
                .mock(),
                responseText: .mock(type: .plainText),
                showImage: false,
                imageUrl: nil
            )
        case .gvaPersistentButton:
            return .gvaPersistentButton(
                .mock(),
                persistenButton: .mock(type: .persistentButtons),
                showImage: false,
                imageUrl: nil
            )
        case .gvaQuickReply:
            return .gvaQuickReply(
                .mock(),
                quickReply: .mock(type: .quickReplies),
                showImage: false,
                imageUrl: nil
            )
        case .gvaGallery:
            return .gvaGallery(
                .mock(),
                gallery: .mock(type: .galleryCards),
                showImage: false,
                imageUrl: nil
            )
        }
    }
}
