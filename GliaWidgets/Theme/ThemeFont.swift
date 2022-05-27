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

    /// Medium subtitle text font. By default, used for question title in survey. Default is Roboto Medium 16.
    public var mediumSubtitle1: UIFont

    /// Second medium subtitle text font. By default, used for status texts in incoming and outcoming chat attachments. Default is Roboto Medium 14.
    public var mediumSubtitle2: UIFont

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
        mediumSubtitle1: UIFont? = nil,
        mediumSubtitle2: UIFont? = nil,
        caption: UIFont? = nil,
        buttonLabel: UIFont? = nil
    ) {
        self.header1 = header1 ?? Font.bold(24)
        self.header2 = header2 ?? Font.regular(20)
        self.header3 = header3 ?? Font.medium(18)
        self.bodyText = bodyText ?? Font.regular(16)
        self.subtitle = subtitle ?? Font.regular(14)
        self.mediumSubtitle1 = mediumSubtitle1 ?? Font.medium(16)
        self.mediumSubtitle2 = mediumSubtitle2 ?? Font.medium(14)
        self.caption = caption ?? Font.regular(12)
        self.buttonLabel = buttonLabel ?? Font.regular(16)
    }

    init() {
        let fontScaling = FontScaling.theme
        self.header1 = fontScaling.uiFont(with: .title1) // header1 ?? Font.bold(24) // .title1
        self.header2 = fontScaling.uiFont(with: .title2) // header2 ?? Font.regular(20) // .title2
        self.header3 = fontScaling.uiFont(with: .title3) // header3 ?? Font.medium(18) // .title3
        self.bodyText = fontScaling.uiFont(with: .body) // bodyText ?? Font.regular(16) // .body
        self.subtitle = fontScaling.uiFont(with: .footnote) // subtitle ?? Font.regular(14) // .footnote
        self.mediumSubtitle1 = fontScaling.uiFont(with: .subheadline, fontSize: 16) // medium16 ?? Font.medium(16)
        self.mediumSubtitle2 = fontScaling.uiFont(with: .subheadline)// mediumSubtitle ?? Font.medium(14) // .subheadline
        self.caption = fontScaling.uiFont(with: .caption1) // caption ?? Font.regular(12) // .caption1
        self.buttonLabel = fontScaling.uiFont(with: .body)// buttonLabel ?? Font.regular(16) // .bodykmj
    }
}

extension FontScaling {
    static let theme = Self(
        descriptions: .init(
            uniqueKeysWithValues: Style
                .allCases
                .map { style in (style, style.themeFontDescription()) }
        ),
        environment: .live
    )
}

extension FontScaling.Description {
    init(name: FontProvider.FontName, size: Double) {
        self.init(name: name.rawValue, size: size)
    }
}

extension FontScaling.Style {
    func themeFontDescription() -> FontScaling.Description {
        #warning("TODO: remove hints-comments")
        switch self {
        case .body:
            return .init(name: .robotoRegular, size: 16) // bodyText ?? Font.regular(16)
        case .callout:
            return .init(name: .robotoRegular, size: 15)
        case .caption1:
            return .init(name: .robotoRegular, size: 12) // caption ?? Font.regular(12)
        case .caption2:
            return .init(name: .robotoRegular, size: 11)
        case .footnote:
            return .init(name: .robotoRegular, size: 14)  // subtitle ?? Font.regular(14) // ???
        case .headline:
            return .init(name: .robotoBold, size: 17)
        case .largeTitle:
            return .init(name: .robotoRegular, size: 34)
        case .subheadline:
            return .init(name: .robotoMedium, size: 14) // mediumSubtitle ?? Font.medium(14)
        case .title1:
            return .init(name: .robotoBold, size: 24) // header1 ?? Font.bold(24)
        case .title2:
            return .init(name: .robotoRegular, size: 20) // header2 ?? Font.regular(20)
        case .title3:
            return .init(name: .robotoMedium, size: 18) // header3 ?? Font.medium(18)
        }
    }
}
