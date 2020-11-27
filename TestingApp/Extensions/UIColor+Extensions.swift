import UIKit

extension UIColor {
    var rgbHexString: String {
        return rgba[0...2].map { String(format: "%02lX", Int($0 * 255)) }.reduce("", +)
    }

    var alphaString: String {
        return String(describing: rgba[3])
    }

    var rgba: [CGFloat] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return [red, green, blue, alpha]
    }

    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
