import UIKit

/// Styles of the choice card's answer options.
public final class ChoiceCardOptionStyle {
    /// Style of an option in an active state - choice card has not been answered by the visitor yet.
    public var normal: ChoiceCardOptionStateStyle

    /// Style of an option in a selected state - choice card has already been answered by the visitor.
    public var selected: ChoiceCardOptionStateStyle

    /// Style of an option in a disabled state - choice card has already been answered by the visitor or the choice card became inactive (e.g. engagement ended).
    public var disabled: ChoiceCardOptionStateStyle

    ///
    /// - Parameters:
    ///   - textFont: Font of an option's text.
    ///   - normalTextColor: Color of an active option's text.
    ///   - normalBackgroundColor: Color of an active option's background.
    ///   - selectedTextColor: Color of a selected option's text.
    ///   - selectedBackgroundColor: Color of a selected option's background.
    ///   - disabledTextColor: Color of a disabled option's text.
    ///   - disabledBackgroundColor: Color of a disabled option's background.
    ///   - disabledBorderColor: Color of a disabled option's border.
    ///
    public init(
        textFont: UIFont,
        normalTextColor: UIColor,
        normalBackgroundColor: UIColor,
        selectedTextColor: UIColor,
        selectedBackgroundColor: UIColor,
        disabledTextColor: UIColor,
        disabledBackgroundColor: UIColor,
        disabledBorderColor: UIColor
    ) {
        self.normal = ChoiceCardOptionStateStyle(
            textFont: textFont,
            textColor: normalTextColor,
            backgroundColor: normalBackgroundColor,
            borderColor: nil
        )
        self.selected = ChoiceCardOptionStateStyle(
            textFont: textFont,
            textColor: selectedTextColor,
            backgroundColor: selectedBackgroundColor,
            borderColor: nil
        )
        self.disabled = ChoiceCardOptionStateStyle(
            textFont: textFont,
            textColor: disabledTextColor,
            backgroundColor: disabledBackgroundColor,
            borderColor: disabledBorderColor
        )
    }
}
