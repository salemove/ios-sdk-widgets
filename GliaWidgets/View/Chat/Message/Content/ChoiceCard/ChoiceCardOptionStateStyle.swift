import UIKit

/// Style of the choice card's option state.
public final class ChoiceCardOptionStateStyle: ChatTextContentStyle {
    /// Color of an option's border.
    public var borderColor: UIColor?
    /// Width of an option's border.
    public var borderWidth: CGFloat

    ///
    /// - Parameters:
    ///   - textFont: Font of an option's text.
    ///   - textColor: Color of an option's text.
    ///   - backgroundColor: Color of an option's background.
    ///   - borderColor: Color of an option's border.
    ///   - borderWidth: Width of an option's border.
    ///   - accessibility: Accessibility related properties.
    public init(
        textFont: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor?,
        borderWidth: CGFloat = 1,
        accessibility: Accessibility = .unsupported
    ) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        super.init(
            textFont: textFont,
            textColor: textColor,
            backgroundColor: backgroundColor,
            accessibility: accessibility
        )
    }

    func apply(configuration: RemoteConfiguration.Button?) {
        configuration?.background?.color?.value
            .map { UIColor(hex: $0) }
            .first
            .map { backgroundColor = $0 }

        configuration?.background?.border?.value
            .map { UIColor(hex: $0) }
            .first
            .map { borderColor = $0 }

        configuration?.background?.borderWidth
            .map { borderWidth = $0 }

        configuration?.text?.foreground?.value
            .map { UIColor(hex: $0) }
            .first
            .map { textColor = $0 }

        configuration?.text?.font?.size
            .map { textFont = Font.regular($0) }
    }
}
