import UIKit

extension SecureConversations.WelcomeStyle {
    ///  Style for file picker button.
    public struct FilePickerButtonStyle: Equatable {
        /// Button image color.
        public var color: UIColor

        /// Button image color for disabled state.
        public var disabledColor: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - color: Button image color.
        ///   - disabledColor: Button image color for disabled state.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            color: UIColor,
            disabledColor: UIColor,
            accessibility: Accessibility
        ) {
            self.color = color
            self.disabledColor = disabledColor
            self.accessibility = accessibility
        }
    }
}
