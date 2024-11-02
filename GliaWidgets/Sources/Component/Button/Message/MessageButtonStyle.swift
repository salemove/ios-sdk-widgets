import Foundation

/// Style for the button shown to the right of the message input area.
public struct MessageButtonStyle {
    /// Style for enabled state of the button.
    public var enabled: MessageButtonStateStyle
    /// Style for disabled state of the button.
    public var disabled: MessageButtonStateStyle

    /// - Parameters:
    ///   - enabled: Style for enabled state of the button.
    ///   - disabled: Style for disabled state of the button.
    public init(
        enabled: MessageButtonStateStyle,
        disabled: MessageButtonStateStyle
    ) {
        self.enabled = enabled
        self.disabled = disabled
    }
}
