import UIKit

extension Theme {
    /// Text style
    public struct Text: Equatable {
        /// Foreground hex color
        public var color: String

        /// Font
        public var font: UIFont

        /// Text style
        public var textStyle: UIFont.TextStyle

        /// Text aligmment
        public var alignment: NSTextAlignment

        /// Accessibility related properties
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - color: Foreground hex color
        ///   - font: Font
        ///   - textStyle: Text style
        ///   - alignment: Text aligmment
        ///   - accessibility: Accessibility related properties
        ///
        public init(
            color: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            alignment: NSTextAlignment = .center,
            accessibility: Accessibility
        ) {
            self.color = color
            self.font = font
            self.textStyle = textStyle
            self.alignment = alignment
            self.accessibility = accessibility
        }
    }
}
