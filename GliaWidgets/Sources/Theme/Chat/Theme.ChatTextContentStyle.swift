import UIKit

public extension Theme {
    /// Style of a text message.
    struct ChatTextContentStyle {
        /// Style of the message text.
        public var text: Text

        /// Style of the content view.
        public var background: Layer

        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - text: Style of the message text.
        ///   - background: Style of the content view.
        ///   - accessibility: Accessibility related properties.
        ///
        public init(
            text: Text,
            background: Layer,
            accessibility: Accessibility = .unsupported
        ) {
            self.text = text
            self.background = background
            self.accessibility = accessibility
        }
    }
}
