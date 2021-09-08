import UIKit

/// Style of a button shown to the right of the message input area. Used for "Send message" and "Pick attachment" buttons.
public struct MessageButtonStyle {
    /// Image of the button.
    public var image: UIImage

    /// Color of the button's image.
    public var color: UIColor

    ///
    /// - Parameters:
    ///   - image: Image of the button.
    ///   - color: Color of the button's image.
    ///
    public init(image: UIImage, color: UIColor) {
        self.image = image
        self.color = color
    }
}
