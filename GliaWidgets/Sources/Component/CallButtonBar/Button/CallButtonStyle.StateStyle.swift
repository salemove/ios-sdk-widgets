import UIKit

extension CallButtonStyle {
    /// Style of a call button ("Chat", "Video", "Mute", "Speaker", and "Minimize")
    /// in a specific state - activated or not activated.
    public struct StateStyle: Equatable {
        /// Background color of the button.
        public var backgroundColor: ColorType

        /// Image of the button.
        public var image: UIImage

        /// Color of the image.
        public var imageColor: ColorType

        /// Title of the button.
        public var title: String

        /// Font of the title.
        public var titleFont: UIFont

        /// Color of the title.
        public var titleColor: UIColor

        /// Text style of the title.
        public var textStyle: UIFont.TextStyle

        /// Accessibility related properties.
        public var accessibility: Accessibility
    }
}
