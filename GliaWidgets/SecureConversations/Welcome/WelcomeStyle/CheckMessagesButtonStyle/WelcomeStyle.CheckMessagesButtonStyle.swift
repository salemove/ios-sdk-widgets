import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for button to check messages.
    public struct CheckMessagesButtonStyle: Equatable {
        /// Button title.
        public var title: String

        /// Font of the button title.
        public var font: UIFont

        /// Text style of the text.
        public var textStyle: UIFont.TextStyle

        /// Color of the button title.
        public var color: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Button title.
        ///   - font: Font of the button title.
        ///   - textStyle: Subtitle text style.
        ///   - color: Color of the button title.
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
