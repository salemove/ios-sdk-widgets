import UIKit

/// Style of an action button. This button contains a title placed on a rectangular background. Used in navigation bar (header).
public struct ActionButtonStyle {
    /// Title of the button.
    public var title: String

    /// Font of the title.
    public var titleFont: UIFont

    /// Color of the title.
    public var titleColor: UIColor

    /// Background color of the button.
    public var backgroundColor: UIColor

    ///
    /// - Parameters:
    ///   - title: Title of the button.
    ///   - titleFont: Font of the title.
    ///   - titleColor: Color of the title.
    ///   - backgroundColor: Background color of the button.
    ///
    public init(title: String,
                titleFont: UIFont,
                titleColor: UIColor,
                backgroundColor: UIColor) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
    }
}
