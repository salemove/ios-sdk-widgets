import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for enabled state of send message button.
    public struct SendButtonEnabledStyle: Equatable {
        /// Title text of the button.
        public var title: String

        /// Font of the title.
        public var font: UIFont

        /// Font style of the text.
        public var textStyle: UIFont.TextStyle

        /// Color of the button title text.
        public var textColor: UIColor

        /// Background color of the button.
        public var backgroundColor: UIColor

        /// Border color of the button.
        public var borderColor: UIColor

        /// Border width of the button.
        public var borderWidth: Double

        /// Corner radius of the button.
        public var cornerRadius: Double

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - borderColor: Border color of the button.
        ///   - borderWidth: Border width of the button.
        ///   - cornerRadius: Corner radius of the button.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            title: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textStyle = textStyle
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.accessibility = accessibility
        }
    }
}
