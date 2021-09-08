import UIKit

/// Style of the operator view inside the connect view.
public struct ConnectOperatorStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle

    /// Color of the animated concentric circles extending from the operator's image.
    public var animationColor: UIColor

    ///
    /// - Parameters:
    ///   - operatorImage: Style of the operator's image.
    ///   - animationColor: Color of the animated concentric circles extending from the operator's image.
    ///
    public init(
        operatorImage: UserImageStyle,
        animationColor: UIColor
    ) {
        self.operatorImage = operatorImage
        self.animationColor = animationColor
    }
}
