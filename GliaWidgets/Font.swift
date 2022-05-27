import UIKit

enum Font {
    static let headerTitle = Font.medium(20)

    @available(*, deprecated, message: "TODO: something about text style")
    static func regular(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: .robotoRegular, size: size)
    }

    @available(*, deprecated, message: "TODO: something about text style")
    static func medium(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: .robotoMedium, size: size)
    }

    @available(*, deprecated, message: "TODO: something about text style")
    static func bold(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: .robotoBold, size: size)
    }
}
