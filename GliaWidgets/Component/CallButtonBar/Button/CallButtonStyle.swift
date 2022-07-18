import UIKit

/// Style of a button shown in call view bottom button bar (i.e. "Chat", "Video", "Mute", "Speaker" and "Minimize").
public struct CallButtonStyle {
    /// Style of a call button ("Chat", "Video", "Mute", "Speaker" and "Minimize") in a specific state - activated or not activated.
    public struct StateStyle {
        /// Background color of the button.
        public var backgroundColor: UIColor

        /// Image of the button.
        public var image: UIImage

        /// Color of the image.
        public var imageColor: UIColor

        /// Title of the button.
        public var title: String

        /// Font of the title.
        public var titleFont: UIFont

        /// Color of the title.
        public var titleColor: UIColor

        /// Accessibility related properties.
        public var accessibility: Accessibility
    }

    /// Style of active (i.e. toggled "on") state.
    public var active: StateStyle

    /// Style of inactive (i.e. toggled "off") state.
    public var inactive: StateStyle

    /// Accessibility related properties.
    public var accessibility: Accessibility
}
