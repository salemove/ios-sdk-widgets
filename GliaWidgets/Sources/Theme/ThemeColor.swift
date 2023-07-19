import UIKit

/// Base colors used in a theme.
public struct ThemeColor {
    /// Primary color used by Widgets. By default used as a header background, visitor chat message background, positive alert button background and in many other places.
    public var primary: UIColor

    /// Secondary color. By default used as a screen share button color.
    public var secondary: UIColor

    /// Base normal color. By default used as a text color in queue/connection views, message input area placeholder, file upload/download information labels and some other minor labels.
    public var baseNormal: UIColor

    /// Base light color. By default used as a text color in chat/call view title, visitor chat message, "End Engagement" button,  queue/connection views and operator name in calls, alert titles and some other labels.
    public var baseLight: UIColor

    /// Base dark color. By default used as a text color in chat queue/connect views, operator chat messages, choice cards, message entry area, upgrade prompts, attachment source list and some other labels.
    public var baseDark: UIColor

    /// Base shade color. By default used as a separator color between message input area and chat, in attachment source list and as a border color in media upgrae prompts.
    public var baseShade: UIColor

    /// Background color. By default used as a background color for chat, message input area and alerts.
    public var background: UIColor

    /// Negative system color. By default used as a background color for "End Engagement" button, negative action button in alerts and as file download/upload error icon, progress bar and text color.
    public var systemNegative: UIColor

    /// Light grey color. By default used as a background for gva persistent buttons and gallery cards.
    public var lightGrey: UIColor

    ///
    /// - Parameters:
    ///   - primary: Primary color used by Widgets. By default used as a header background, visitor chat message background, positive alert button background and in many other places.
    ///   - secondary: Secondary color. By default used as a screen share button color.
    ///   - baseNormal: Base normal color. By default used as a text color in queue/connection views, message input area placeholder, file upload/download information labels and some other minor labels.
    ///   - baseLight: Base light color. By default used as a text color in chat/call view title, visitor chat message, "End Engagement" button,  queue/connection views and operator name in calls, alert titles and some other labels.
    ///   - baseDark: Base dark color. By default used as a text color in chat queue/connect views, operator chat messages, choice cards, message entry area, upgrade prompts, attachment source list and some other labels.
    ///   - baseShade: Base shade color. By default used as a separator color between message input area and chat, in attachment source list and as a border color in media upgrae prompts.
    ///   - background: Background color. By default used as a background color for chat, message input area and alerts.
    ///   - systemNegative: Negative system color. By default used as a background color for "End Engagement" button, negative action button in alerts and as file download/upload error icon, progress bar and text color.
    public init(
        primary: UIColor? = nil,
        secondary: UIColor? = nil,
        baseNormal: UIColor? = nil,
        baseLight: UIColor? = nil,
        baseDark: UIColor? = nil,
        baseShade: UIColor? = nil,
        background: UIColor? = nil,
        systemNegative: UIColor? = nil,
        lightGrey: UIColor? = nil
    ) {
        self.primary = primary ?? Color.primary
        self.secondary = secondary ?? Color.secondary
        self.baseNormal = baseNormal ?? Color.baseNormal
        self.baseLight = baseLight ?? Color.baseLight
        self.baseDark = baseDark ?? Color.baseDark
        self.baseShade = baseShade ?? Color.baseShade
        self.background = background ?? Color.background
        self.systemNegative = systemNegative ?? Color.systemNegative
        self.lightGrey = lightGrey ?? Color.lightGrey
    }
}
