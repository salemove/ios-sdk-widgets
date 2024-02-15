import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for message title.
    public struct MessageTitleStyle: Equatable {
        /// Message title text.
        public var title: String

        /// Font of the message title.
        public var font: UIFont

        /// Text style of the text.
        public var textStyle: UIFont.TextStyle

        /// Color of the message title.
        public var color: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Message title text.
        ///   - font: Font of the message title.
        ///   - textStyle: Subtitle text style.
        ///   - color: Color of the message title.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            title: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textStyle = textStyle
            self.color = color
            self.accessibility = accessibility
        }
    }
}
