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

        ///
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

extension Theme.ChatTextContentStyle {
    /// Accessibility properties for ChatTextContentStyle.
    public struct Accessibility: Equatable {
        /// Accessibility value.
        public var value: String

        /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public var isFontScalingEnabled: Bool

        ///
        /// - Parameters:
        ///   - value: Accessibility value.
        ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
        public init(
            value: String = "",
            isFontScalingEnabled: Bool
        ) {
            self.value = value
            self.isFontScalingEnabled = isFontScalingEnabled
        }

        /// Accessibility is not supported intentionally.
        public static let unsupported = Self(
            value: "",
            isFontScalingEnabled: false
        )
    }
}
