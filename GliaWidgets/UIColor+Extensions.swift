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

    private static let trimmingCharacters = CharacterSet.whitespacesAndNewlines.union(.init(charactersIn: "#"))

    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex: String = hex.trimmingCharacters(in: Self.trimmingCharacters)
        let scanner = Scanner(string: hex)

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = CGFloat(Int(color >> 16) & mask) / 255.0
        let g = CGFloat(Int(color >> 8) & mask) / 255.0
        let b = CGFloat(Int(color) & mask) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
