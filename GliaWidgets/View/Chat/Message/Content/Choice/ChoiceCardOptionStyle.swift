import UIKit

/// Styles of the choice card's answer options.
public final class ChoiceCardOptionStyle {
    /// Style of an option in an active state - choice card has not been answered by the visitor yet.
    public var normal: ChatTextContentStyle

    /// Style of an option in a selected state - choice card has already been answered by the visitor.
    public var selected: ChatTextContentStyle

    /// Style of an option in a disabled state - choice card has already been answered by the visitor or the choice card became inactive (e.g. engagement ended).
    public var disabled: ChatTextContentStyle

    ///
    /// - Parameters:
    ///   - textFont: Font of an option's text.
    ///   - normalTextColor: Color of an active option's text.
    ///   - normalBackgroundColor: Color of an active option's background.
    ///   - highlightedTextColor: Color of a selected option's text.
    ///   - highlightedBackgroundColor: Color of a selected option's background.
    ///   - disabledTextColor: Color of a disabled option's text.
    ///   - disabledBackgroundColor: Color of a disabled option's background.
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
