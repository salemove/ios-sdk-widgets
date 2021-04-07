import UIKit

/// Style of a button shown in call button bar.
public struct CallButtonStyle {
    /// Style of a button's state.
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

    /// Style of active state.
    public var active: StateStyle

    /// Style of inactive state.
    public var inactive: StateStyle
}
