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
    ///   - normal: Style of an option in an active state - choice card has not been answered by the visitor yet.
    ///   - selected: Style of an option in a selected state - choice card has already been answered by the visitor.
    ///   - disabled: Style of an option in a disabled state - choice card has already been answered by the visitor or the choice card became inactive (e.g. engagement ended).
    ///
    public init(
        normal: ChoiceCardOptionStateStyle,
        selected: ChoiceCardOptionStateStyle,
        disabled: ChoiceCardOptionStateStyle
    ) {
        self.normal = normal
        self.selected = selected
        self.disabled = disabled
    }

    func apply(configuration: RemoteConfiguration.ResponseCardOption?) {
        normal.apply(configuration: configuration?.normal)
        selected.apply(configuration: configuration?.selected)
        disabled.apply(configuration: configuration?.disabled)
    }
}
