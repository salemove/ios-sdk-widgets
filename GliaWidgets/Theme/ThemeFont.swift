import UIKit

public struct ThemeFont {
    let header1: UIFont
    let header2: UIFont
    let header3: UIFont
    let bodyText: UIFont
    let subtitle: UIFont
    let caption: UIFont
    let buttonLabel: UIFont

    public init(header1: UIFont? = nil,
                header2: UIFont? = nil,
                header3: UIFont? = nil,
                bodyText: UIFont? = nil,
                subtitle: UIFont? = nil,
                caption: UIFont? = nil,
                buttonLabel: UIFont? = nil) {
        self.header1 = header1 ?? Font.bold(24)
        self.header2 = header2 ?? Font.regular(20)
        self.header3 = header3 ?? Font.medium(18)
        self.bodyText = bodyText ?? Font.regular(16)
        self.subtitle = subtitle ?? Font.regular(14)
        self.caption = caption ?? Font.regular(12)
        self.buttonLabel = buttonLabel ?? Font.regular(16)
    }
}
