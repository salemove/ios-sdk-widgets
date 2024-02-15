import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for description showm in the welcome area.
    public struct SubtitleStyle: Equatable {
        /// Subtitle text value.
        public var text: String

        /// Subtitle font.
        public var font: UIFont

        /// Text style of the text.
        public var textStyle: UIFont.TextStyle

        /// Subtitle color.
        public var color: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Subtitle text value.
        ///   - font: Subtitle font.
        ///   - textStyle: Subtitle text style.
        ///   - color: Subtitle color.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            text: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.text = text
            self.font = font
            self.textStyle = textStyle
            self.color = color
            self.accessibility = accessibility
        }
    }
}
