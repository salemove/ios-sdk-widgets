import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255.0,
            green: CGFloat((hex >> 8) & 0xff) / 255.0,
            blue: CGFloat(hex & 0xff) / 255.0,
            alpha: alpha
        )
    }

    var hex: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: UInt = (UInt)(r * 255) << 16 | (UInt)(g * 255) << 8 | (UInt)(b * 255) << 0

        return NSString(format: "#%06x", rgb) as String
     }

    private static let trimmingCharacters = CharacterSet.whitespacesAndNewlines.union(.init(charactersIn: "#"))

    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex: String = hex.trimmingCharacters(in: Self.trimmingCharacters)
        let scanner = Scanner(string: hex)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x000000FF
        let r = CGFloat(Int(color >> 16) & mask) / 255.0
        let g = CGFloat(Int(color >> 8) & mask) / 255.0
        let b = CGFloat(Int(color) & mask) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
