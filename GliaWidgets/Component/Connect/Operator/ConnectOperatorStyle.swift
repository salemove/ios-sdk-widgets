import UIKit

/// Style of the operator view inside the connect view.
public struct ConnectOperatorStyle {
    /// Style of the operator's image.
    public var operatorImage: UserImageStyle

    /// Color of the animated concentric circles extending from the operator's image.
    public var animationColor: UIColor

    /// Style of the visitor on hold overlay view.
    public var onHoldOverlay: OnHoldOverlayStyle

    ///
    /// - Parameters:
    ///   - operatorImage: Style of the operator's image.
    ///   - animationColor: Color of the animated concentric circles extending from the operator's image.
    ///   - onHoldOverlay: Style of the visitor on hold overlay view.
    ///
    public init(
        operatorImage: UserImageStyle,
        animationColor: UIColor,
        onHoldOverlay: OnHoldOverlayStyle = .engagement
    ) {
        self.operatorImage = operatorImage
        self.animationColor = animationColor
        self.onHoldOverlay = onHoldOverlay
    }
}
