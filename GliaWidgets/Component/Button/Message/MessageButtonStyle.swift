import UIKit

/// Style of a button shown in the message input area.
public struct MessageButtonStyle {
    /// Image of the button.
    public var image: UIImage

    /// Color of the button.
    public var color: UIColor

    ///
    /// - Parameters:
    ///   - image: Image of the button.
    ///   - color: Color of the button.
    ///
    public init(image: UIImage, color: UIColor) {
        self.image = image
        self.color = color
    }
}
