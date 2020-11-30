import UIKit

public struct ChatOperatorImageStyle {
    public var placeholderImage: UIImage?
    public var placeholderColor: UIColor
    public var animationColor: UIColor

    public init(placeholderImage: UIImage?,
                placeholderColor: UIColor,
                animationColor: UIColor) {
        self.placeholderImage = placeholderImage
        self.placeholderColor = placeholderColor
        self.animationColor = animationColor
    }
}
