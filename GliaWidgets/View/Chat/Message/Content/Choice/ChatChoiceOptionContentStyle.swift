import UIKit

public class ChatChoiceOptionContentStyle: ChatTextContentStyle {
    public var highlightedTextColor: UIColor
    public var highlightedBackgroundColor: UIColor

    public init(
        textFont: UIFont,
        textColor: UIColor,
        highlightedTextColor: UIColor,
        backgroundColor: UIColor,
        highlightedBackgroundColor: UIColor
    ) {
        self.highlightedTextColor = highlightedTextColor
        self.highlightedBackgroundColor = highlightedBackgroundColor
        super.init(
            textFont: textFont,
            textColor: textColor,
            backgroundColor: backgroundColor
        )
    }
}
