import UIKit

class SettingsColorCell: SettingsCell {
    var color: UIColor { UIColor(hex: textField.text ?? "") ?? .black }

    private let textField = UITextField()

    public init(title: String, color: UIColor) {
        textField.text = color.hexString
        super.init(title: title)
        setup()
        layout()
    }

    private func setup() {
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .allCharacters
    }

    private func layout() {
        contentView.addSubview(textField)
        textField.autoSetDimension(.width, toSize: 100)
        textField.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 20, relation: .greaterThanOrEqual)
        textField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20),
                                               excludingEdge: .left)
    }
}

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return [r, g, b].map { String(format: "%02lX", Int($0 * 255)) }.reduce("", +)
    }

    convenience init?(hex: String) {
        let r, g, b: CGFloat

        let start = hex.startIndex
        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0x00ff00) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                b = CGFloat((hexNumber & 0x000000ff) >> 0) / 255

                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        }

        return nil
    }
}
