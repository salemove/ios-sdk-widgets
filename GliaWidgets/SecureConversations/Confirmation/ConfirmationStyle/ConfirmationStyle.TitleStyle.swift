import UIKit

extension SecureConversations.ConfirmationStyle {
    /// Style for title shown in the confirmation area.
    public struct TitleStyle: Equatable {
        /// Title text value.
        public var text: String

        /// Title font.
        public var font: UIFont

        /// Title color.
        public var color: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Title text value.
        ///   - font: Title font.
        ///   - color: Title color.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            text: String,
            font: UIFont,
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.text = text
            self.font = font
            self.color = color
            self.accessibility = accessibility
        }
    }
}
