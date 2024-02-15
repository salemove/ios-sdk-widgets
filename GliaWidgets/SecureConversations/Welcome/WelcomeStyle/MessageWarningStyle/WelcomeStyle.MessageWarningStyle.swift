import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for message warning section.
    public struct MessageWarningStyle: Equatable {
        /// Color of the warning text.
        public var textColor: UIColor

        /// Font of the warning text.
        public var textFont: UIFont

        /// Text style of the text.
        public var textStyle: UIFont.TextStyle

        /// Color of the warning icon image.
        public var iconColor: UIColor

        /// Text for the message limit warning.
        public var messageLengthLimitText: String

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - textColor: Color of the warning text.
        ///   - textFont: Font of the warning text.
        ///   - textStyle: Font style of the warning text.
        ///   - iconColor: Color of the warning icon image.
        ///   - messageLengthLimitText: Text for the message limit warning.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            textColor: UIColor,
            textFont: UIFont,
            textStyle: UIFont.TextStyle,
            iconColor: UIColor,
            messageLengthLimitText: String,
            accessibility: Accessibility
        ) {
            self.textColor = textColor
            self.textFont = textFont
            self.textStyle = textStyle
            self.iconColor = iconColor
            self.messageLengthLimitText = messageLengthLimitText
            self.accessibility = accessibility
        }
    }
}
