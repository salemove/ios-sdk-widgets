import UIKit

/// Base fonts used in a theme.
public struct ThemeFont {
    /// Biggest header font. By default, used in top label of connection view during queue and for operator's name during audio or video call. Default is Roboto Bold 24.
    public var header1: UIFont

    /// Second biggest header font. By default, used in both labels in the connection view when connecting to operator and for titles in chat view header and alerts. Default is Roboto Regular 20.
    public var header2: UIFont

    /// Third biggest header font. By default, used in media upgrade alerts' titles. Default is Roboto Medium 18.
    public var header3: UIFont

    /// Main body text font. By default, mostly used in chat messages and message input area, as well as attachment source title labels. Default is Roboto Regular 16.
    public var bodyText: UIFont

    /// Subtitle text font. By default, used for title in the call view header, second label in connect view when connected to operator and for file extension in chat attachments. Default is Roboto Regular 14.
    public var subtitle: UIFont

    /// Medium subtitle text font. By default, used for status texts in incoming and outcoming chat attachments. Default is Roboto Medium 14.
    public var mediumSubtitle: UIFont

    /// Caption text font. By default, used for visitor message status text ("Delivered"), unread message badge label, chat attachment information labels and call view button labels. Default is Roboto Regular 12.
    public var caption: UIFont

    /// Button label text font. By default, used in "End" buttons in chat and call view headers and buttons in alerts. Default is Roboto Regular 16.
    public var buttonLabel: UIFont

    ///
    /// - Parameters:
    ///   - header1: Biggest header font. By default, used in top label of connection view during queue and for operator's name during audio or video call. Default is Roboto Bold 24.
    ///   - header2: Second biggest header font. By default, used in both labels in the connection view when connecting to operator and for titles in chat view header and alerts. Default is Roboto Regular 20.
    ///   - header3: Third biggest header font. By default, used in media upgrade alerts' titles. Default is Roboto Medium 18.
    ///   - bodyText: Main body text font. By default, mostly used in chat messages and message input area, as well as attachment source title labels. Default is Roboto Regular 16.
    ///   - subtitle: Subtitle text font. By default, used for title in the call view header, second label in connect view when connected to operator and for file extension in chat attachments. Default is Roboto Regular 14.
    ///   - mediumSubtitle: Medium subtitle text font. By default, used for status texts in incoming and outcoming chat attachments. Default is Roboto Medium 14.
    ///   - caption: Caption text font. By default, used for visitor message status text ("Delivered"), unread message badge label, chat attachment information labels and call view button labels. Default is Roboto Regular 12.
    ///   - buttonLabel: Button label text font. By default, used in "End" buttons in chat and call view headers and buttons in alerts. Default is Roboto Regular 16.
    public init(
        header1: UIFont? = nil,
        header2: UIFont? = nil,
        header3: UIFont? = nil,
        bodyText: UIFont? = nil,
        subtitle: UIFont? = nil,
        mediumSubtitle: UIFont? = nil,
        caption: UIFont? = nil,
        buttonLabel: UIFont? = nil
    ) {
        self.header1 = header1 ?? Font.bold(24)
        self.header2 = header2 ?? Font.regular(20)
        self.header3 = header3 ?? Font.medium(18)
        self.bodyText = bodyText ?? Font.regular(16)
        self.subtitle = subtitle ?? Font.regular(14)
        self.mediumSubtitle = mediumSubtitle ?? Font.medium(14)
        self.caption = caption ?? Font.regular(12)
        self.buttonLabel = buttonLabel ?? Font.regular(16)
    }
}
