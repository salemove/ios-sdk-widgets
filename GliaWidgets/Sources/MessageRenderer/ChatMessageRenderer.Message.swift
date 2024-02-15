import UIKit
import GliaCoreSDK

public extension MessageRenderer {
    /// Message to render AI custom card view.
    struct Message {
        public typealias Identifier = Tagged<Self, String>

        /// Message ID
        public let id: Identifier

        /// Message metadata. Use `decode()` method to decode into decodable model.
        public let metadata: MessageMetadata?

        /// Selected option value.
        public let selectedOption: String?

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
