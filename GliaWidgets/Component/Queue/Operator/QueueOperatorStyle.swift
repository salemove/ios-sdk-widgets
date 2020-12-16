import UIKit

public struct QueueOperatorStyle {
    public var operatorImage: UserImageStyle
    public var animationColor: UIColor

    public init(operatorImage: UserImageStyle,
                animationColor: UIColor) {
        self.operatorImage = operatorImage
        self.animationColor = animationColor
    }
}
