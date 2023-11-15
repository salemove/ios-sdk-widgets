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
        let hex: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let start = hex.index(hex.startIndex, offsetBy: hex.hasPrefix("#") ? 1 : 0)
        let hexColor = String(hex[start...])

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
            let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
            let b = CGFloat(hexNumber & 0x0000ff) / 255.0

            self.init(red: r, green: g, blue: b, alpha: alpha)
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }
}
