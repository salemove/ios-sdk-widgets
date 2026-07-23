import Foundation

public extension MessageRenderer {
    /// Message to render AI custom card view.
    struct Message {
        typealias Identifier = CoreSdkClient.Tagged<Self, String>

        /// Message ID
        let id: Identifier

        /// Message metadata. Use `decode()` method to decode into decodable model.
        let metadata: MessageMetadata?

        /// Selected option value.
        let selectedOption: String?

        /// - Parameters:
        ///   - id: message ID
        ///   - metadata: Message metadata. Use `decode()` method to decode into decodable model.
        ///   - selectedOption: Selected option value.
        ///
        init(chatMessage: ChatMessage) {
            self.id = .init(rawValue: chatMessage.id)
            self.metadata = chatMessage.metadata
            self.selectedOption = chatMessage.attachment?.selectedOption
        }
    }
}
