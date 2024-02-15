import Foundation

public struct GvaGalleryListViewStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle

    /// Style of the gallery card.
    public var cardStyle: GvaGalleryCardStyle

    /// - Parameters:
    ///   - operatorImage: Style of the operator's image.
    ///   - cardStyle: Style of the gallery card.
    ///
    public init(
        operatorImage: UserImageStyle,
        cardStyle: GvaGalleryCardStyle
    ) {
        self.operatorImage = operatorImage
        self.cardStyle = cardStyle
    }
}

extension GvaGalleryListViewStyle {
    static var initial: GvaGalleryListViewStyle {
        .init(
            operatorImage: .initial,
            cardStyle: .initial
        )
    }
}
