import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for message text view.
    public struct MessageTextViewStyle: Equatable {
        /// Style of normal state for message text view.
        public var normalStyle: MessageTextViewNormalStyle

        /// Style of disabled state for message text view.
        public var disabledStyle: MessageTextViewDisabledStyle

        /// Style of active state for message text view.
        public var activeStyle: MessageTextViewActiveStyle

        /// - Parameters:
        ///   - normalStyle: Style of normal state for message text view.
        ///   - disabledStyle: Style of disabled state for message text view.
        ///   - activeStyle: Style of active state for message text view.
        ///
        public init(
            normalStyle: SecureConversations.WelcomeStyle.MessageTextViewNormalStyle,
            disabledStyle: SecureConversations.WelcomeStyle.MessageTextViewDisabledStyle,
            activeStyle: SecureConversations.WelcomeStyle.MessageTextViewActiveStyle
        ) {
            self.normalStyle = normalStyle
            self.disabledStyle = disabledStyle
            self.activeStyle = activeStyle
        }
    }
}
