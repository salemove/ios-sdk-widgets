import UIKit

public struct GvaGalleryCardStyle {
    /// Style of the card container.
    public var cardContainer: ViewStyle
    /// Style of the image view.
    public var imageView: ViewStyle
    /// Style of the card title.
    public var title: TextStyle
    /// Style of the card subtitle.
    public var subtitle: TextStyle
    /// Style of the card buttons.
    public var button: ButtonStyle

    /// Initialize `GvaGalleryCardStyle` instance.
    /// - Parameters:
    ///   - cardContainer: Style of the card container.
    ///   - imageView: Style of the image view.
    ///   - title: Style of the card title.
    ///   - subtitle: Style of the card subtitle.
    ///   - button: Style of the card buttons.
    public init(
        cardContainer: ViewStyle,
        imageView: ViewStyle,
        title: TextStyle,
        subtitle: TextStyle,
        button: ButtonStyle
    ) {
        self.cardContainer = cardContainer
        self.imageView = imageView
        self.title = title
        self.subtitle = subtitle
        self.button = button
    }

    static var initial: GvaGalleryCardStyle {
        .init(
            cardContainer: .initial,
            imageView: .initial,
            title: .initial,
            subtitle: .initial,
            button: .initial
        )
    }

    mutating func apply(
        configuration: RemoteConfiguration.GVAGalleryCardStyle?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        cardContainer.apply(configuration: configuration?.cardContainer)
        imageView.apply(configuration: configuration?.imageView)
        button.apply(
            configuration: configuration?.button,
            assetBuilder: assetBuilder
        )
        title.apply(
            configuration: configuration?.title,
            assetBuilder: assetBuilder
        )
        subtitle.apply(
            configuration: configuration?.subtitle,
            assetBuilder: assetBuilder
        )
    }
}

public extension GvaGalleryCardStyle {
    struct ViewStyle {
        /// Background color of the view.
        public var backgroundColor: ColorType
        /// Corner radius of the view.
        public var cornerRadius: CGFloat
        /// Color of the view's border.
        public var borderColor: UIColor
        /// Width of the view's border.
        public var borderWidth: CGFloat

        /// Initialize `ViewStyle` instance.
        /// - Parameters:
        ///   - backgroundColor: Background color of the view.
        ///   - cornerRadius: Corner radius of the view.
        ///   - borderColor: Color of the view's border.
        ///   - borderWidth: Width of the view's border.
        public init(
            backgroundColor: ColorType,
            cornerRadius: CGFloat,
            borderColor: UIColor,
            borderWidth: CGFloat
        ) {
            self.backgroundColor = backgroundColor
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
        }

        static var initial: ViewStyle {
            .init(
                backgroundColor: .fill(color: .clear),
                cornerRadius: 0,
                borderColor: .clear,
                borderWidth: 0
            )
        }

        mutating func apply(configuration: RemoteConfiguration.Layer?) {
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

    struct TextStyle {
        /// Font of the card text label.
        public var font: UIFont
        /// Color of the card text label.
        public var textColor: UIColor
        /// Text style of the card text label.
        public var textStyle: UIFont.TextStyle

        /// Initialize `TextStyle` instance.
        /// - Parameters:
        ///   - font: Font of the card text label.
        ///   - textColor: Color of the card text label.
        ///   - textStyle: Text style of the card text label.
        public init(
            font: UIFont,
            textColor: UIColor,
            textStyle: UIFont.TextStyle
        ) {
            self.font = font
            self.textColor = textColor
            self.textStyle = textStyle
        }

        static var initial: TextStyle {
            .init(
                font: .systemFont(ofSize: 12),
                textColor: .black,
                textStyle: .body
            )
        }

        mutating func apply(
            configuration: RemoteConfiguration.Text?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            UIFont.convertToFont(
                uiFont: assetBuilder.fontBuilder(configuration?.font),
                textStyle: textStyle
            ).unwrap { font = $0 }

            configuration?.foreground?.value
                .map { UIColor(hex: $0) }
                .first
                .unwrap { textColor = $0 }
        }
    }

    struct ButtonStyle {
        /// Style of the button title.
        public var title: TextStyle
        /// Style of the button background.
        public var background: ViewStyle

        /// Initialize `ButtonStyle` instance.
        /// - Parameters:
        ///   - title: Style of the button title.
        ///   - background: Style of the button background.
        public init(
            title: TextStyle,
            background: ViewStyle
        ) {
            self.title = title
            self.background = background
        }

        static var initial: ButtonStyle {
            .init(
                title: .initial,
                background: .initial
            )
        }

        mutating func apply(
            configuration: RemoteConfiguration.Button?,
            assetBuilder: RemoteConfiguration.AssetsBuilder
        ) {
            title.apply(
                configuration: configuration?.text,
                assetBuilder: assetBuilder
            )
            background.apply(configuration: configuration?.background)
        }
    }
}
