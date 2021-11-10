import UIKit

/// Style of a button shown in call view bottom button bar (i.e. "Chat", "Video", "Mute", "Speaker" and "Minimize").
public struct CallButtonStyle {
    /// Style of a call button ("Chat", "Video", "Mute", "Speaker" and "Minimize") in a specific state - active or inactive.
    public struct StateStyle {
        /// Background color of the button.
        public let backgroundColor: UIColor

        /// Image of the button.
        public let image: UIImage

        /// Color of the image.
        public let imageColor: UIColor

        /// Title of the button.
        public let title: String

        /// Font of the title.
        public let titleFont: UIFont

        /// Color of the title.
        public let titleColor: UIColor
    }

    /// Style of active (i.e. can be pressed) state.
    public var active: StateStyle

    /// Style of inactive (i.e. can not be pressed) state.
    public var inactive: StateStyle
}
