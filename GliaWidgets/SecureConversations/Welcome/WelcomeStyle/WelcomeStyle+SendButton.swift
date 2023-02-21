import UIKit

extension SecureConversations.WelcomeStyle {
    /// Style for send message button.
    public struct SendButtonStyle: Equatable {
        /// Style for enabled state of send message button.
        public var enabledStyle: SendButtonEnabledStyle
        /// Style for disabled state of send message button.
        public var disabledStyle: SendButtonDisabledStyle
        /// Style for loading state of send message button.
        public var loadingStyle: SendButtonLoadingStyle

        /// - Parameters:
        ///   - enabledStyle: Style for enabled state of send message button.
        ///   - disabledStyle: Style for disabled state of send message button.
        ///   - loadingStyle: Style for loading state of send message button.
        public init(
            enabledStyle: SecureConversations.WelcomeStyle.SendButtonEnabledStyle,
            disabledStyle: SecureConversations.WelcomeStyle.SendButtonDisabledStyle,
            loadingStyle: SendButtonLoadingStyle
        ) {
            self.enabledStyle = enabledStyle
            self.disabledStyle = disabledStyle
            self.loadingStyle = loadingStyle
        }

        mutating func apply(
            enabled: RemoteConfiguration.Button?,
            disabled: RemoteConfiguration.Button?,
            loading: RemoteConfiguration.Button?,
            activityIndicatorColor: RemoteConfiguration.Color?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            enabledStyle.apply(
                configuration: enabled,
                assetBuilder: assetBuilder
            )
            disabledStyle.apply(
                configuration: disabled,
                assetBuilder: assetBuilder
            )
            loadingStyle.apply(
                configuration: loading,
                activityIndicatorColor: activityIndicatorColor,
                assetBuilder: assetBuilder
            )
        }
    }

    /// Style for enabled state of send message button.
    public struct SendButtonEnabledStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Font style of the text.
        public var textStyle: UIFont.TextStyle
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor
        /// Border color of the button.
        public var borderColor: UIColor
        /// Border width of the button.
        public var borderWidth: Double
        /// Corner radius of the button.
        public var cornerRadius: Double
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - borderColor: Border color of the button.
        ///   - borderWidth: Border width of the button.
        ///   - cornerRadius: Corner radius of the button.
        public init(
            title: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textStyle = textStyle
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.accessibility = accessibility
        }

        /// Accessibility properties for SendButtonEnabledStyle.
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
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
        }

        mutating func apply(
            configuration: RemoteConfiguration.Button?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetBuilder.fontBuilder(configuration?.text?.font),
                textStyle: textStyle
            ).unwrap { font = $0 }

            configuration?.text?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { textColor = $0 }

            configuration?.background?.color?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { backgroundColor = $0 }

            configuration?.background?.border?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { borderColor = $0 }

            if let borderWidth = configuration?.background?.borderWidth {
                self.borderWidth = borderWidth
            }

            if let cornerRadius = configuration?.background?.cornerRadius {
                self.cornerRadius = cornerRadius
            }
        }
    }

    /// Style for disabled state of send message button.
    public struct SendButtonDisabledStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Font style of the text.
        public var textStyle: UIFont.TextStyle
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor
        /// Border color of the button.
        public var borderColor: UIColor
        /// Border width of the button.
        public var borderWidth: Double
        /// Corner radius of the button.
        public var cornerRadius: Double
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - borderColor: Border color of the button.
        ///   - borderWidth: Border width of the button.
        ///   - cornerRadius: Corner radius of the button.
        public init(
            title: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            cornerRadius: Double,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textStyle = textStyle
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.accessibility = accessibility
        }

        /// Accessibility properties for SendButtonDisabledStyle.
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
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
        }

        mutating func apply(
            configuration: RemoteConfiguration.Button?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetBuilder.fontBuilder(configuration?.text?.font),
                textStyle: textStyle
            ).unwrap { font = $0 }

            configuration?.text?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { textColor = $0 }

            configuration?.background?.color?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { backgroundColor = $0 }

            configuration?.background?.border?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { borderColor = $0 }

            if let borderWidth = configuration?.background?.borderWidth {
                self.borderWidth = borderWidth
            }

            if let cornerRadius = configuration?.background?.cornerRadius {
                self.cornerRadius = cornerRadius
            }
        }
    }

    /// Style for loading state of send message button.
    public struct SendButtonLoadingStyle: Equatable {
        /// Title text of the button.
        public var title: String
        /// Font of the title.
        public var font: UIFont
        /// Font style of the text.
        public var textStyle: UIFont.TextStyle
        /// Color of the button title text.
        public var textColor: UIColor
        /// Background color of the button.
        public var backgroundColor: UIColor
        /// Border color of the button.
        public var borderColor: UIColor
        /// Border width of the button.
        public var borderWidth: Double
        /// Color of the activity indicator of the button.
        public var activityIndicatorColor: UIColor
        /// Corner radius of the button.
        public var cornerRadius: Double
        /// Accessibility related properties.
        public var accessibility: Accessibility

        /// - Parameters:
        ///   - title: Title text of the button.
        ///   - font: Font of the title.
        ///   - textColor: Color of the button title text.
        ///   - backgroundColor: Background color of the button.
        ///   - borderColor: Border color of the button.
        ///   - borderWidth: Border width of the button.
        ///   - activityIndicatorColor: Color of the activity indicator of the button.
        ///   - cornerRadius: Corner radius of the button.
        public init(
            title: String,
            font: UIFont,
            textStyle: UIFont.TextStyle,
            textColor: UIColor,
            backgroundColor: UIColor,
            borderColor: UIColor,
            borderWidth: Double,
            activityIndicatorColor: UIColor,
            cornerRadius: Double,
            accessibility: Accessibility
        ) {
            self.title = title
            self.font = font
            self.textStyle = textStyle
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.activityIndicatorColor = activityIndicatorColor
            self.accessibility = accessibility
        }

        /// Accessibility properties for SendButtonEnabledStyle.
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
                label: String,
                hint: String
            ) {
                self.isFontScalingEnabled = isFontScalingEnabled
                self.label = label
                self.hint = hint
            }

            /// Accessibility is not supported intentionally.
            public static let unsupported = Self(
                isFontScalingEnabled: false,
                label: "",
                hint: ""
            )
        }

        mutating func apply(
            configuration: RemoteConfiguration.Button?,
            activityIndicatorColor: RemoteConfiguration.Color?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetBuilder.fontBuilder(configuration?.text?.font),
                textStyle: textStyle
            ).unwrap { font = $0 }

            configuration?.text?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { textColor = $0 }

            configuration?.background?.color?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { backgroundColor = $0 }

            configuration?.background?.border?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { borderColor = $0 }

            if let borderWidth = configuration?.background?.borderWidth {
                self.borderWidth = borderWidth
            }

            activityIndicatorColor?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { self.activityIndicatorColor = $0 }

            if let cornerRadius = configuration?.background?.cornerRadius {
                self.cornerRadius = cornerRadius
            }
        }
    }
}
