import UIKit

/// Style of the on hold overlay view (used in bubble & call views).
public struct OnHoldOverlayStyle: Equatable {
    /// The overlay image.
    public var image: UIImage

    /// The overlay image color.
    public var imageColor: ColorType

    /// The overlay image size.
    public var imageSize: CGSize

    /// The overlay background color.
    public var backgroundColor: ColorType

    /// - Parameters:
    ///   - image: The overlay image.
    ///   - imageColor: The overlay image color.
    ///   - imageSize: The overlay image size.
    ///   - backgroundColor: The overlay background color.
    ///
    public init(
        image: UIImage,
        imageColor: ColorType,
        imageSize: CGSize,
        backgroundColor: ColorType = .fill(color: .clear)
    ) {
        self.image = image
        self.imageColor = imageColor
        self.imageSize = imageSize
        self.backgroundColor = backgroundColor
    }
}

public extension OnHoldOverlayStyle {
    static var bubble: OnHoldOverlayStyle = .init(
        image: Asset.callOnHold.image,
        imageColor: .fill(color: .white),
        imageSize: .init(width: 26, height: 26)
    )

    static var engagement: OnHoldOverlayStyle = .init(
        image: Asset.callOnHold.image,
        imageColor: .fill(color: .white),
        imageSize: .init(width: 40, height: 40)
    )
}
