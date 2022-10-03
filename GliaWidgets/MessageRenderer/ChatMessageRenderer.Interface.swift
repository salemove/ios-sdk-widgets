import UIKit
import SalemoveSDK

/// Message renderer for AI custom cards.
public struct MessageRenderer {
    /// Closure returning the custom card view for the message.
    public var render: (Message) -> UIView?
    /// Closure returning boolean value indicating whether the custom card view is interactable.
    public var isInteractable: (Message) -> Bool
    /// Closure returning boolean value indicating the custom card view should be shown when the card is interactable and option is selected.
    public var shouldShowCard: (Message) -> Bool
    /// Void closure that receives selected string-based mobile action.
    public var callMobileActionHandler: (String) -> Void

    ///
    /// - Parameters:
    ///   - render: Closure returning the custom card view for the message.
    ///   - isInteractable: Closure returning boolean value indicating whether the custom card view is interactable.
    ///   - shouldShowCard: Closure returning boolean value indicating the custom card view should be shown when the card is interactable and option is selected.
    ///   - callMobileActionHandler: Void closure that receives selected string-based mobile action.
    ///
    public init(
        render: @escaping (Message) -> UIView?,
        isInteractable: @escaping (Message) -> Bool = { _ in false },
        shouldShowCard: @escaping (Message) -> Bool = { _ in true },
        callMobileActionHandler: @escaping (String) -> Void = { _ in }
    ) {
        self.render = render
        self.isInteractable = isInteractable
        self.shouldShowCard = shouldShowCard
        self.callMobileActionHandler = callMobileActionHandler
    }
}

public extension MessageRenderer {
    /// Message to render AI custom card view.
    struct Message {
        public typealias Identifier = Tagged<Self, String>
        /// Message id.
        public let id: Identifier
        /// Message metadata. Use `decode()` method to decode into decodable model.
        public let metadata: MessageMetadata?
        /// Selected option value.
        public let selectedOption: String?

        init(chatMessage: ChatMessage) {
            self.id = .init(rawValue: chatMessage.id)
            self.metadata = chatMessage.metadata
            self.selectedOption = chatMessage.attachment?.selectedOption
        }
    }
}
