import SalemoveSDK

protocol ChatMessage {
    var sender: MessageSender { get }
    var content: String { get }
}

extension Message: ChatMessage {}
extension ChatStorage.Message: ChatMessage {}
