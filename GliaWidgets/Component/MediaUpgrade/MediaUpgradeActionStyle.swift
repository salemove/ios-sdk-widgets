import UIKit

/// Style of the media upgrade action in a multiple media type alert window. Currently unused.
public struct MediaUpgradeActionStyle {
    /// Title of the media upgrade action. Displayed to the left of the icon, at the top of the view.
    public var title: String

    /// Font of the title.
    public var titleFont: UIFont

    /// Color of the title.
    public var titleColor: UIColor

    /// Additional information about the media upgrade action. Displayed to the left of the icon, below the title.
    public var info: String

    /// Font of the additional information text.
    public var infoFont: UIFont

    /// Color of the additional information text.
    public var infoColor: UIColor

    /// Color of the border for the entire media upgrade action view. Border width is 1.
    public var borderColor: UIColor

    /// Background color of the entire media upgrade action view.
    public var backgroundColor: UIColor

    /// Icon that is displayed in the left side of the media upgrade action view.
    public var icon: UIImage

    /// Color (tint) of the icon.
    public var iconColor: UIColor


    ///
    /// - Parameters:
    ///   - title: Title of the media upgrade action. Displayed to the left of the icon, at the top of the view.
    ///   - titleFont: Font of the title.
    ///   - titleColor: Color of the title.
    ///   - info: Additional information about the media upgrade action. Displayed to the left of the icon, below the title.
    ///   - infoFont: Font of the additional information text.
    ///   - infoColor: Color of the additional information text.
    ///   - borderColor: Color of the border for the entire media upgrade action view. Border width is 1.
    ///   - backgroundColor: Background color of the entire media upgrade action view.
    ///   - icon: Icon that is displayed in the left side of the media upgrade action view.
    ///   - iconColor: Color (tint) of the icon.
    public init(
        title: String,
        titleFont: UIFont,
        titleColor: UIColor,
        info: String,
        infoFont: UIFont,
        infoColor: UIColor,
        borderColor: UIColor,
        backgroundColor: UIColor,
        icon: UIImage,
        iconColor: UIColor
    ) {
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.info = info
        self.infoFont = infoFont
        self.infoColor = infoColor
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
        self.icon = icon
        self.iconColor = iconColor
    }
}
