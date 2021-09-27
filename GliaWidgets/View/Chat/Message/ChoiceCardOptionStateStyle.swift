import UIKit

/// Styles of the choice card's options state.
public final class ChoiceCardOptionStateStyle: ChatTextContentStyle {
    /// Color of an option's border.
    public var borderColor: UIColor?

    ///
    /// - Parameters:
    ///   - textFont: Font of an option's text.
    ///   - textColor: Color of an option's text.
    ///   - backgroundColor: Color of an option's background.
    ///   - borderColor: Color of an option's border.
    ///
    public init(
        textFont: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor?
    ) {
        self.borderColor = borderColor
        super.init(
            textFont: textFont,
            textColor: textColor,
            backgroundColor: backgroundColor
        )
    }
}
