import UIKit

enum Font {
    static let headerTitle = Font.medium(20)

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
