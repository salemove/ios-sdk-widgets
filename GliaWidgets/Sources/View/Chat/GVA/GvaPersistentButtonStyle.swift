import UIKit

/// Style of the GVA Persistent Button container
public struct GvaPersistentButtonStyle {
    /// Title of the container
    public var title: ChatTextContentStyle

    /// Background of the container
    public var backgroundColor: ColorType

    /// Corner radius of the container
    public var cornerRadius: CGFloat

    /// Border width of the container
    public var borderWidth: CGFloat

    /// Border color of the container
    public var borderColor: UIColor

    /// Persistent Button
    public var button: ButtonStyle

    /// Initialization of the object
    public init(
        title: ChatTextContentStyle,
        backgroundColor: ColorType,
        cornerRadius: CGFloat,
        borderWidth: CGFloat,
        borderColor: UIColor,
        button: ButtonStyle
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.button = button
    }

    mutating func apply(
        _ configuration: RemoteConfiguration.GvaPersistentButton?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        applyBackgroundConfiguration(configuration?.background)
        applyTitleConfiguration(configuration?.title, assetBuilder: assetBuilder)
        button.apply(configuration?.button, assetBuilder: assetBuilder)
    }

    mutating private func applyTitleConfiguration(
        _ configuration: RemoteConfiguration.Text?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        UIFont.convertToFont(
            uiFont: assetBuilder.fontBuilder(configuration?.font),
            textStyle: title.textStyle
        ).unwrap { title.textFont = $0 }

        configuration?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { title.textColor = $0 }
    }

    mutating private func applyBackgroundConfiguration(_ configuration: RemoteConfiguration.Layer?) {
        configuration?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { borderColor = $0 }

        configuration?.borderWidth
            .unwrap { borderWidth = $0 }

        configuration?.cornerRadius
            .unwrap { cornerRadius = $0 }

        configuration?.color.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { backgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                backgroundColor = .gradient(colors: colors)
            }
        }
    }
}

extension GvaPersistentButtonStyle {
    /// Style of the Persistent Button
    public struct ButtonStyle {
        /// Font of the button
        public var textFont: UIFont

        /// Color of the button
        public var textColor: UIColor

        /// Text style of the button
        public var textStyle: UIFont.TextStyle

        /// Background of the button
        public var backgroundColor: ColorType

        /// Corner radius of the button
        public var cornerRadius: CGFloat

        /// Border color of the button
        public var borderColor: UIColor

        /// Border width of the button
        public var borderWidth: CGFloat

        init(
            textFont: UIFont,
            textColor: UIColor,
            textStyle: UIFont.TextStyle = .title2,
            backgroundColor: ColorType,
            cornerRadius: CGFloat,
            borderColor: UIColor,
            borderWidth: CGFloat
        ) {
            self.textFont = textFont
            self.textColor = textColor
            self.textStyle = textStyle
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
        }

        mutating func apply(
            _ configuration: RemoteConfiguration.Button?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            applyTitleConfiguration(configuration?.text, assetBuilder: assetBuilder)
            applyBackgroundConfiguration(configuration?.background)
        }

        mutating private func applyTitleConfiguration(
            _ configuration: RemoteConfiguration.Text?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetBuilder.fontBuilder(configuration?.font),
                textStyle: textStyle
            ).unwrap { textFont = $0 }

            configuration?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { textColor = $0 }
        }

        mutating private func applyBackgroundConfiguration(_ configuration: RemoteConfiguration.Layer?) {
            configuration?.border?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { borderColor = $0 }

            configuration?.borderWidth
                .unwrap { borderWidth = $0 }

            configuration?.cornerRadius
                .unwrap { cornerRadius = $0 }

            configuration?.color.unwrap {
                switch $0.type {
                case .fill:
                    $0.value
                        .map { UIColor(hex: $0) }
                        .first
                        .unwrap { backgroundColor = .fill(color: $0) }
                case .gradient:
                    let colors = $0.value.convertToCgColors()
                    backgroundColor = .gradient(colors: colors)
                }
            }
        }
    }
}
