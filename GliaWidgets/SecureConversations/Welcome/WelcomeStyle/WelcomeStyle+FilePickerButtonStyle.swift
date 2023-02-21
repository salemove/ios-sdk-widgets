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
        public init(
            color: UIColor,
            disabledColor: UIColor,
            accessibility: Accessibility
        ) {
            self.color = color
            self.disabledColor = disabledColor
            self.accessibility = accessibility
        }

        /// Accessibility properties for FilePickerButtonStyle.
        public struct Accessibility: Equatable {
            /// Flag that provides font dynamic type by setting `adjustsFontForContentSizeCategory` for component that supports it.
            public var isFontScalingEnabled: Bool
            /// Accessibility label.
            public var label: String
            /// Accessibility hint.
            public var hint: String

            /// - Parameters:
            ///   - isFontScalingEnabled: Flag that provides font dynamic type by setting
            ///    `adjustsFontForContentSizeCategory` for component that supports it.
            ///   - label: Accessibility label.
            ///   - hint: Accessibility hint.
            public init(
                isFontScalingEnabled: Bool,
                accessibilityLabel: String,
                accessibilityHint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = accessibilityLabel
                self.hint = accessibilityHint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                accessibilityLabel: "",
                accessibilityHint: ""
            )
        }

        mutating func apply(
            configuration: RemoteConfiguration.Color?,
            disabledConfiguration: RemoteConfiguration.Color?
        ) {
            configuration?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { color = $0 }
            disabledConfiguration?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { disabledColor = $0 }
        }
    }
}
