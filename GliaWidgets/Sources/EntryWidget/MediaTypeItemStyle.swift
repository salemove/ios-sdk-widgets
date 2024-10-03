import UIKit

extension EntryWidgetStyle {
    public struct MediaTypeItemStyle {
        /// Font of the headline text.
        public var titleFont: UIFont

        /// Color of the headline text.
        public var titleColor: UIColor

        /// Text style of the message text.
        public var titleTextStyle: UIFont.TextStyle

        /// Font of the subheadline (message) text.
        public var messageFont: UIFont

        /// Color of the subheadline (message) text.
        public var messageColor: UIColor

        /// Text style of the message text.
        public var messageTextStyle: UIFont.TextStyle

        /// Color of the icon.
        public var iconColor: ColorType

        /// Background color of the view.
        public var backgroundColor: ColorType

        /// - Parameters:
        ///   - titleFont: Font of the headline text.
        ///   - titleColor: Color of the headline text.
        ///   - titleTextStyle: The style of the title text.
        ///   - messageFont: Font of the subheadline (message) text.
        ///   - messageColor: Color of the subheadline (message) text.
        ///   - messageTextStyle: The style of the title text.
        ///   - iconColor: Color of the icon.
        ///   - backgroundColor: Background color of the view.
        ///
        public init(
            titleFont: UIFont,
            titleColor: UIColor,
            titleTextStyle: UIFont.TextStyle,
            messageFont: UIFont,
            messageColor: UIColor,
            messageTextStyle: UIFont.TextStyle,
            iconColor: ColorType,
            backgroundColor: ColorType
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.titleTextStyle = titleTextStyle
            self.messageFont = messageFont
            self.messageColor = messageColor
            self.messageTextStyle = messageTextStyle
            self.iconColor = iconColor
            self.backgroundColor = backgroundColor
        }
    }
}
