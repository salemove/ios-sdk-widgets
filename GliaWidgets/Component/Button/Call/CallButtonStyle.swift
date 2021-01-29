import UIKit

public struct CallButtonStyle {
    public struct StateStyle {
        public let backgroundColor: UIColor
        public let image: UIImage
        public let imageColor: UIColor
        public let title: String
        public let titleFont: UIFont
        public let titleColor: UIColor
    }

    public var active: StateStyle
    public var inactive: StateStyle
}
