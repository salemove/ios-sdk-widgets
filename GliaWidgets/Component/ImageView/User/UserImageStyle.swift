import UIKit

/// Style of a view showing user image.
public struct UserImageStyle {
    /// Placeholder image. It is shown if the user's image is not set or not available.
    public var placeholderImage: UIImage?

    /// Color of the placeholder image.
    public var placeholderColor: UIColor

    /// Color of the placeholder background.
    public var placeholderBackgroundColor: UIColor

    /// Background color of the image (in case it has transparency).
    public var imageBackgroundColor: UIColor

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
        placeholderBackgroundColor: UIColor,
        imageBackgroundColor: UIColor,
        transferringImage: UIImage? = nil
    ) {
        self.placeholderImage = placeholderImage
        self.placeholderColor = placeholderColor
        self.placeholderBackgroundColor = placeholderBackgroundColor
        self.imageBackgroundColor = imageBackgroundColor
        self.transferringImage = transferringImage
    }

    /// Apply user image remote configuration
    mutating func applyUserImageConfiguration(_ userImage: RemoteConfiguration.UserImageStyle?) {
        userImage?.imageBackgroundColor?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                userImage?.imageBackgroundColor?.value.map {
                    imageBackgroundColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        userImage?.placeholderColor?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                userImage?.placeholderColor?.value.map {
                    placeholderColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }

        userImage?.placeholderBackgroundColor?.type.map { backgroundType in
            switch backgroundType {
            case .fill:
                userImage?.placeholderBackgroundColor?.value.map {
                    placeholderBackgroundColor = UIColor(hex: $0[0])
                }
            case .gradient:

            /// The logic for gradient has not been implemented

                break
            }
        }
    }
}
