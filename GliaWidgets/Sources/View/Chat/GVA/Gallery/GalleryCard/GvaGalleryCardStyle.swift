import UIKit

public struct GvaGalleryCardStyle {
    /// Style of the card container.
    public let cardContainer: ViewStyle
    /// Style of the image view.
    public let imageView: ViewStyle
    /// Style of the card title.
    public let title: TextStyle
    /// Style of the card subtitle.
    public let subtitle: TextStyle
    /// Style of the card buttons.
    public let button: ButtonStyle

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
}

public extension GvaGalleryCardStyle {
    struct ViewStyle {
        /// Background color of the view.
        public let backgroundColor: ColorType
        /// Corner radius of the view.
        public let cornerRadius: CGFloat
        /// Color of the view's border.
        public let borderColor: UIColor
        /// Width of the view's border.
        public let borderWidth: CGFloat

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
    }

    struct TextStyle {
        /// Font of the card text label.
        public let font: UIFont
        /// Color of the card text label.
        public let textColor: UIColor
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
    }

    struct ButtonStyle {
        /// Style of the button title.
        public let title: TextStyle
        /// Style of the button background.
        public let background: ViewStyle

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
    }
}
