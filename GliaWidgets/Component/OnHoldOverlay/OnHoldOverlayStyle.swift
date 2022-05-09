import UIKit

/// Style of the on hold overlay view (used in bubble & call views).
public struct OnHoldOverlayStyle {
    public var image: UIImage
    public var imageColor: UIColor
    public var imageSize: CGSize

    public init(
        image: UIImage,
        imageColor: UIColor,
        imageSize: CGSize
    ) {
        self.image = image
        self.imageColor = imageColor
        self.imageSize = imageSize
    }
}

public extension OnHoldOverlayStyle {
    static var bubble: OnHoldOverlayStyle = .init(
        image: Asset.callOnHold.image,
        imageColor: .white,
        imageSize: .init(width: 26, height: 26)
    )

    static var engagement: OnHoldOverlayStyle = .init(
        image: Asset.callOnHold.image,
        imageColor: .white,
        imageSize: .init(width: 40, height: 40)
    )
}
