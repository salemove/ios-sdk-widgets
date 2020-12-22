import UIKit

public class OperatorChatMessageStyle: ChatMessageStyle {
    public var operatorImage: UserImageStyle

    public init(messageFont: UIFont,
                messageColor: UIColor,
                backgroundColor: UIColor,
                operatorImage: UserImageStyle) {
        self.operatorImage = operatorImage
        super.init(messageFont: messageFont,
                   messageColor: messageColor,
                   backgroundColor: backgroundColor)
    }
}
