import Foundation

public struct GvaGalleryListViewStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle
    /// Style of the gallery card.
    public var cardStyle: GvaGalleryCardStyle

    /// Initializes `GvaGalleryListViewStyle` instance.
    /// - Parameters:
    ///   - operatorImage: Style of the operator's image.
    ///   - cardStyle: Style of the gallery card.
    public init(
        operatorImage: UserImageStyle,
        cardStyle: GvaGalleryCardStyle
    ) {
        self.operatorImage = operatorImage
        self.cardStyle = cardStyle
    }

    static var initial: GvaGalleryListViewStyle {
        .init(
            operatorImage: .initial,
            cardStyle: .initial
        )
    }

    mutating func apply(
        configuration: RemoteConfiguration.GvaGalleryCards?,
        assetBuilder: RemoteConfiguration.AssetsBuilder
    ) {
        operatorImage.apply(configuration: configuration?.operatorImage)
        cardStyle.apply(
            configuration: configuration?.cardStyle,
            assetBuilder: assetBuilder
        )
    }
}
