import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for send message button.
    public struct SendButtonStyle: Equatable {
        /// Style for enabled state of send message button.
        public var enabledStyle: SendButtonEnabledStyle

        /// Style for disabled state of send message button.
        public var disabledStyle: SendButtonDisabledStyle

        /// Style for loading state of send message button.
        public var loadingStyle: SendButtonLoadingStyle

        /// - Parameters:
        ///   - enabledStyle: Style for enabled state of send message button.
        ///   - disabledStyle: Style for disabled state of send message button.
        ///   - loadingStyle: Style for loading state of send message button.
        ///
        public init(
            enabledStyle: SecureConversations.WelcomeStyle.SendButtonEnabledStyle,
            disabledStyle: SecureConversations.WelcomeStyle.SendButtonDisabledStyle,
            loadingStyle: SendButtonLoadingStyle
        ) {
            self.enabledStyle = enabledStyle
            self.disabledStyle = disabledStyle
            self.loadingStyle = loadingStyle
        }
    }
}
