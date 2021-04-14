import UIKit

public class ChoiceCardOptionStyle {
    public var normal: ChatTextContentStyle
    public var selected: ChatTextContentStyle
    public var disabled: ChatTextContentStyle

    public init(
        textFont: UIFont,
        normalTextColor: UIColor,
        normalBackgroundColor: UIColor,
        highlightedTextColor: UIColor,
        highlightedBackgroundColor: UIColor,
        disabledTextColor: UIColor,
        disabledBackgroundColor: UIColor
    ) {
        self.normal = ChatTextContentStyle(
            textFont: textFont,
            textColor: normalTextColor,
            backgroundColor: normalBackgroundColor
        )
        self.selected = ChatTextContentStyle(
            textFont: textFont,
            textColor: highlightedTextColor,
            backgroundColor: highlightedBackgroundColor
        )
        self.disabled = ChatTextContentStyle(
            textFont: textFont,
            textColor: disabledTextColor,
            backgroundColor: disabledBackgroundColor
        )
    }
}
