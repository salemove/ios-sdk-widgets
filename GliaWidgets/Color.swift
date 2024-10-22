import UIKit

enum Color {
    static let primary = UIColor(hex: 0x0F6BFF) // blue
    static let secondary = UIColor(hex: 0x18901C) // green
    static let baseLight = UIColor(hex: 0xFFFFFF) // white
    static let systemNegative = UIColor(hex: 0xBC0F42) // red
    static let baseNormal = UIColor(hex: 0x616A75) // grey
    // TODO: Confirm transparency of shade color, since it is different from dedicated color tokens palette.
    static let baseShade = UIColor(hex: 0x6C7683, alpha: 0.5)
    static let baseDark = UIColor(hex: 0x2C0735) // purple
    static let baseNeutral = UIColor(hex: 0xF7F7F7) // light gray
}
