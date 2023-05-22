import Foundation
import GliaCoreSDK

// MARK: Custom cards
extension SecureConversations.TranscriptModel {
    func isInteractableCustomCard(_ chatMessage: ChatMessage) -> Bool {
        let message = MessageRenderer.Message(chatMessage: chatMessage)
        return chatMessage.isCustomCard && (isInteractableCard?(message) ?? false)
    }
}
