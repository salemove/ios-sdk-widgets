import UIKit

extension SecureConversations.ConfirmationStyle {
    /// Style for button to check messages.
    public struct CheckMessagesButtonStyle: Equatable {
        /// Title text of the button.
        public var title: String

        /// Font of the title.
        public var font: UIFont

        /// Color of the button title text.
        public var textColor: UIColor

        /// Background color of the button.
        public var backgroundColor: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            title: String,
            font: UIFont,
            textColor: UIColor,
            backgroundColor: UIColor,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.accessibility = accessibility
        }
    }
}
