import UIKit

/// Style of a button shown in call view bottom button bar 
/// (i.e. "Chat", "Video", "Mute", "Speaker, and "Minimize").
public struct CallButtonStyle: Equatable {
    /// Style of active state.
    public var active: StateStyle

    /// Style of inactive state.
    public var inactive: StateStyle

    /// Style of selected state.
    public var selected: StateStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility
}
