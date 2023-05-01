import Foundation
import SalemoveSDK

// MARK: Custom cards
extension SecureConversations.TranscriptModel {
    func isInteractableCustomCard(_ chatMessage: ChatMessage) -> Bool {
        let message = MessageRenderer.Message(chatMessage: chatMessage)
        return chatMessage.isCustomCard && (isInteractableCard?(message) ?? false)
    }
}
