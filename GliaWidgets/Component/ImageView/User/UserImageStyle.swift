import UIKit

public struct UserImageStyle {
    public var placeholderImage: UIImage?
    public var placeholderColor: UIColor
    public var backgroundColor: UIColor

    public init(placeholderImage: UIImage?,
                placeholderColor: UIColor,
                backgroundColor: UIColor) {
        self.placeholderImage = placeholderImage
        self.placeholderColor = placeholderColor
        self.backgroundColor = backgroundColor
    }
}
