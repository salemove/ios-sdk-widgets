import UIKit

/// Style of a view showing user image.
public struct UserImageStyle: Equatable {
    /// Placeholder image. It is shown if the user's image is not set or not available.
    public var placeholderImage: UIImage?

    /// Color of the placeholder image.
    public var placeholderColor: UIColor

    /// Color of the placeholder background.
    public var placeholderBackgroundColor: ColorType

    /// Background color of the image (in case it has transparency).
    public var imageBackgroundColor: ColorType

    /// Transferring image. It is shown if the visitor is being transferred to another operator.
    public var transferringImage: UIImage?

    /// 
    /// - Parameters:
    ///   - placeholderImage: Placeholder image.
    ///   - placeholderColor: Color of the placeholder image.
    ///   - placeholderBackgroundColor: Color of the placeholder background.
    ///   - imageBackgroundColor: Background color of the image (in case it has transparency).
    ///   - transferringImage: Transferring image. It is shown if the visitor is being transferred to another operator.
    public init(
        placeholderImage: UIImage?,
        placeholderColor: UIColor,
        placeholderBackgroundColor: ColorType,
        imageBackgroundColor: ColorType,
        transferringImage: UIImage? = nil
    ) {
        self.placeholderImage = placeholderImage
        self.placeholderColor = placeholderColor
        self.placeholderBackgroundColor = placeholderBackgroundColor
        self.imageBackgroundColor = imageBackgroundColor
        self.transferringImage = transferringImage
    }

    mutating func apply(configuration: RemoteConfiguration.UserImageStyle?) {
        configuration?.placeholderColor?.value
            .map { UIColor(hex: $0) }
            .first
            .unwrap { placeholderColor = $0 }

        configuration?.placeholderBackgroundColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { placeholderBackgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                placeholderBackgroundColor = .gradient(colors: colors)
            }
        }

        configuration?.imageBackgroundColor.unwrap {
            switch $0.type {
            case .fill:
                $0.value
                    .map { UIColor(hex: $0) }
                    .first
                    .unwrap { imageBackgroundColor = .fill(color: $0) }
            case .gradient:
                let colors = $0.value.convertToCgColors()
                imageBackgroundColor = .gradient(colors: colors)
            }
        }
    }
}
