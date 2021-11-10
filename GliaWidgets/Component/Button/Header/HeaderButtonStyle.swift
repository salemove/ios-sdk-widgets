import UIKit

/// Style of a button that only consists of a single image. It is displayed in the app navigation bar (header). Used for "Back", "Exit queue" and "End screen share" buttons.
public struct HeaderButtonStyle {
    /// Image of the button.
    public var image: UIImage?

    /// Color of the button's image.
    public var color: UIColor

    ///
    /// - Parameters:
    ///   - image: Image of the button.
    ///   - color: Color of the button's image.
    ///
    public init(image: UIImage?, color: UIColor) {
        self.image = image
        self.color = color
    }
}
