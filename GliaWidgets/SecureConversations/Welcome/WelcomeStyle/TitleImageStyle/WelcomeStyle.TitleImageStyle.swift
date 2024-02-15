import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for title icon image.
    public struct TitleImageStyle: Equatable {
        /// Color of the image.
        public var color: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - color: Color of the image.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            color: UIColor,
            accessibility: Accessibility
        ) {
            self.color = color
            self.accessibility = accessibility
        }
    }
}
