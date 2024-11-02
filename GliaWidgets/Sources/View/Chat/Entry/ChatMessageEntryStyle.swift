import UIKit

/// Style of the message entry area.
public struct ChatMessageEntryStyle {
    /// Style of the enabled message entry area.
    public var enabled: ChatMessageEntryStateStyle
    /// Style of the disabled message entry area.
    public var disabled: ChatMessageEntryStateStyle

    /// - Parameters:
    ///   - enabled: Style of the enabled message entry area.
    ///   - disabled: Style of the disabled message entry area.
    public init(
        enabled: ChatMessageEntryStateStyle,
        disabled: ChatMessageEntryStateStyle
    ) {
        self.enabled = enabled
        self.disabled = disabled
    }
}
