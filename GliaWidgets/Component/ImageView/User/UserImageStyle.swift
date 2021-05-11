import UIKit

public struct UserImageStyle {
    public var placeholderImage: UIImage?
    public var placeholderColor: UIColor
    public var placeholderBackgroundColor: UIColor
    public var imageBackgroundColor: UIColor

    public init(
        placeholderImage: UIImage?,
        placeholderColor: UIColor,
        placeholderBackgroundColor: UIColor,
        imageBackgroundColor: UIColor
    ) {
        self.placeholderImage = placeholderImage
        self.placeholderColor = placeholderColor
        self.placeholderBackgroundColor = placeholderBackgroundColor
        self.imageBackgroundColor = imageBackgroundColor
    }
}
