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

    /// - Parameters:
    ///   - cardContainer: Style of the card container.
    ///   - imageView: Style of the image view.
    ///   - title: Style of the card title.
    ///   - subtitle: Style of the card subtitle.
    ///   - button: Style of the card buttons.
    ///
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
}

extension GvaGalleryCardStyle {
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
