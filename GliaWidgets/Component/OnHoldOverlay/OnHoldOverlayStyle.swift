import UIKit

/// Style of the on hold overlay view (used in bubble & call views).
public struct OnHoldOverlayStyle {
    public var image: UIImage
    public var imageColor: ColorType
    public var imageSize: CGSize

    public init(
        image: UIImage,
        imageColor: ColorType,
        imageSize: CGSize
    ) {
        self.image = image
        self.imageColor = imageColor
        self.imageSize = imageSize
    }

    /// Apply onHoldOverlay style remote configuration
    mutating func apply(configuration: RemoteConfiguration.OnHoldOverlayStyle?) {
        configuration?.color.map {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .map { imageColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                imageColor = .gradient(colors: colors)
            }
        }
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
