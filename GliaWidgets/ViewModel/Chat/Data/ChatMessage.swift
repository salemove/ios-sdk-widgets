import SalemoveSDK

protocol ChatMessage {
    var id: String { get }
    var sender: MessageSender { get }
    var content: String { get }
}

extension Message: ChatMessage {}
extension ChatStorage.Message: ChatMessage {}
