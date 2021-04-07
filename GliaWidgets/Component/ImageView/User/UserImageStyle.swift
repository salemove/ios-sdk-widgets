import UIKit

/// Style of a view showing user image.
public struct UserImageStyle {
    /// Placeholder image.
    public var placeholderImage: UIImage?

    /// Color of the placeholder image.
    public var placeholderColor: UIColor

    /// Background color of the view.
    public var backgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - placeholderImage: Placeholder image.
    ///   - placeholderColor: Color of the placeholder image.
    ///   - backgroundColor: Background color of the view.
    ///
    public init(placeholderImage: UIImage?,
                placeholderColor: UIColor,
                backgroundColor: UIColor) {
        self.placeholderImage = placeholderImage
        self.placeholderColor = placeholderColor
        self.backgroundColor = backgroundColor
    }
}
