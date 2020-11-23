import UIKit

public enum Font {
    public static let header1 = Font.bold(24)
    public static let header2 = Font.regular(20)
    public static let header3 = Font.medium(18)
    public static let bodyText = Font.regular(16)
    public static let subtitle = Font.regular(14)
    public static let caption = Font.regular(12)

    public static let headerTitle = Font.medium(20)

    static func regular(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: "Roboto-Regular", size: size)
    }

    static func medium(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: "Roboto-Medium", size: size)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: "Roboto-Bold", size: size)
    }
}
