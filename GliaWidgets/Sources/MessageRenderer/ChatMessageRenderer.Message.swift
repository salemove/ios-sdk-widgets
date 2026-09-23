@_spi(GliaWidgets) internal import GliaCoreSDK
import Foundation

public extension MessageRenderer {
    /// Message to render AI custom card view.
    struct Message {
        public struct Identifier: RawRepresentable, Hashable, Codable, ExpressibleByStringLiteral {
            public var rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }

            public init(stringLiteral value: String) {
                self.init(rawValue: value)
            }

            public init(from decoder: Decoder) throws {
                self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(rawValue)
            }
        }

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
