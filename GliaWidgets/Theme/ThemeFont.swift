import UIKit

public struct ThemeFont {
    let header1: UIFont
    let header2: UIFont
    let header3: UIFont
    let bodyText: UIFont
    let subtitle: UIFont
    let caption: UIFont

    public init(regular: UIFont? = nil,
                medium: UIFont? = nil,
                bold: UIFont? = nil) {
        let regular = regular ?? Font.regular(1)
        let medium = medium ?? Font.medium(1)
        let bold = bold ?? Font.bold(1)

        header1 = bold.withSize(24)
        header2 = regular.withSize(20)
        header3 = medium.withSize(18)
        bodyText = regular.withSize(16)
        subtitle = regular.withSize(14)
        caption = regular.withSize(12)
    }
}
