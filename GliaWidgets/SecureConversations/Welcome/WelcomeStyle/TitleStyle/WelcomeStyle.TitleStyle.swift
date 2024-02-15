import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for title shown in the welcome area.
    public struct TitleStyle: Equatable {
        /// Title text value.
        public var text: String

        /// Title text font.
        public var font: UIFont

        /// Text text style.
        public var textStyle: UIFont.TextStyle

        /// Title color.
        public var color: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Title text value.
        ///   - font: Title text font.
        ///   - textStyle: Text text style.
        ///   - color: Title color.
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
