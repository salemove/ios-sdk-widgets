import UIKit

// MARK: - Accessibility
extension ChatView {
    static func operatorAccessibilityMessage(
        for chatMessage: ChatMessage,
        `operator`: String,
        isFontScalingEnabled: Bool
    ) -> ChatMessageContent.TextAccessibilityProperties {
        .init(
            label: chatMessage.operator?.name ?? `operator`,
            value: chatMessage.content,
            isFontScalingEnabled: isFontScalingEnabled
        )
    }

    static func visitorAccessibilityMessage(
        for chatMessage: ChatMessage,
        visitor: String,
        isFontScalingEnabled: Bool
    ) -> ChatMessageContent.TextAccessibilityProperties {
        .init(
            label: visitor,
            value: chatMessage.content,
            isFontScalingEnabled: isFontScalingEnabled
        )
    }

    static func visitorAccessibilityOutgoingMessage(
        for outgoingMessage: OutgoingMessage,
        visitor: String,
        isFontScalingEnabled: Bool
    ) -> ChatMessageContent.TextAccessibilityProperties {
        .init(
            label: visitor,
            value: outgoingMessage.content,
            isFontScalingEnabled: isFontScalingEnabled
        )
    }
}
