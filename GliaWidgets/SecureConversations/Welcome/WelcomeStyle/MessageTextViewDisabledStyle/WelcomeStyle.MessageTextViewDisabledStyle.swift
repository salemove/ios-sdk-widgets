import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style of disabled state for message text view.
    public struct MessageTextViewDisabledStyle: Equatable {
        /// Placeholder text for text view.
        public var placeholderText: String

        /// Font for placeholder text.
        public var placeholderFont: UIFont

        /// Color for placeholder text.
        public var placeholderColor: UIColor

        /// Font for the text of text view.
        public var textFont: UIFont

        /// Font for placeholder text style.
        public var textFontStyle: UIFont.TextStyle

        /// Color of the text.
        public var textColor: UIColor

        /// Color of the border of the text view.
        public var borderColor: UIColor

        /// Width of border for the text view.
        public var borderWidth: Double

        /// Border corner radius.
        public var cornerRadius: Double

        /// Color of the background of the text view.
        public var backgroundColor: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - placeholderText: Placeholder text for text view.
        ///   - placeholderFont: Font for placeholder text.
        ///   - placeholderColor: Color for placeholder text.
        ///   - textFont: Font for the text of text view.
        ///   - textFontStyle: Font style for the text of text view.
        ///   - textColor: Color of the text.
        ///   - borderColor: Color of the border of the text view.
        ///   - borderWidth: Width of border for the text view.
        ///   - cornerRadius: Border corner radius.
        ///   - backgroundColor: Color of the background of the text view.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            placeholderText: String,
            placeholderFont: UIFont,
            placeholderColor: UIColor,
            textFont: UIFont,
            textFontStyle: UIFont.TextStyle,
            textColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            backgroundColor: UIColor,
            accessibility: Accessibility
        ) {
            self.placeholderText = placeholderText
            self.placeholderFont = placeholderFont
            self.placeholderColor = placeholderColor
            self.textFont = textFont
            self.textFontStyle = textFontStyle
            self.textColor = textColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.accessibility = accessibility
        }
    }
}
