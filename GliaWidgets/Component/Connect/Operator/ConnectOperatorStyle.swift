import UIKit

public struct ConnectOperatorStyle {
    public var operatorImage: UserImageStyle
    public var animationColor: UIColor

    public init(operatorImage: UserImageStyle,
                animationColor: UIColor) {
        self.operatorImage = operatorImage
        self.animationColor = animationColor
    }
}
