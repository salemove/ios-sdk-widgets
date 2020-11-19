import UIKit

enum Font {
    static func regular(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: "Roboto-Regular", size: size)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        FontProvider.shared.font(named: "Roboto-Bold", size: size)
    }
}
