import UIKit

public struct EntryWidgetStyle {
    /// Engagement channel style.
    public var channel: EntryWidgetChannelStyle

    /// Background color of the view.
    public var backgroundColor: UIColor

    /// Style of 'powered by' view.
    public var poweredBy: PoweredByStyle

    /// The color of the dragger
    public var draggerColor: UIColor

    /// - Parameters:
    ///   - channel: Engagement channel style.
    ///   - backgroundColor: Background color of the view.
    ///   - poweredBy: Style of 'powered by' view.
    ///   - draggerColor: The color of the dragger
    ///
    public init(
        channel: EntryWidgetChannelStyle,
        backgroundColor: UIColor,
        poweredBy: PoweredByStyle,
        draggerColor: UIColor
    ) {
        self.channel = channel
        self.backgroundColor = backgroundColor
        self.poweredBy = poweredBy
        self.draggerColor = draggerColor
    }
}

public struct EntryWidgetChannelStyle {
    /// Font of the headline text.
    public var headlineFont: UIFont

    /// Color of the headline text.
    public var headlineColor: UIColor

    /// Font of the subheadline text.
    public var subheadlineFont: UIFont

    /// Color of the subheadline text.
    public var subheadlineColor: UIColor

    /// Color of the icon.
    public var iconColor: UIColor

    /// - Parameters:
    ///   - headlineFont: Font of the headline text.
    ///   - headlineColor: Color of the headline text.
    ///   - subheadlineFont: Font of the subheadline text.
    ///   - subheadlineColor: Color of the subheadline text.
    ///   - iconColor: Color of the icon.
    ///
    public init(
        headlineFont: UIFont,
        headlineColor: UIColor,
        subheadlineFont: UIFont,
        subheadlineColor: UIColor,
        iconColor: UIColor
    ) {
        self.headlineFont = headlineFont
        self.headlineColor = headlineColor
        self.subheadlineFont = subheadlineFont
        self.subheadlineColor = subheadlineColor
        self.iconColor = iconColor
    }
}
