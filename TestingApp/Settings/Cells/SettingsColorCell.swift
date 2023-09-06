import UIKit

class SettingsColorCell: SettingsCell {
    var color: UIColor {
        let rgbHex = rgbTextField.text ?? ""
        let alpha = CGFloat(((alphaTextField.text ?? "") as NSString).floatValue)
        return UIColor(hex: rgbHex, alpha: alpha)
    }

    private let sampleView = UIView()
    private let rgbTextField = UITextField()
    private let alphaTextField = UITextField()

    init(title: String, color: UIColor) {
        rgbTextField.text = color.rgbHexString
        alphaTextField.text = color.alphaString
        super.init(title: title)
        setup()
        layout()
    }

    private func setup() {
        rgbTextField.borderStyle = .roundedRect
        rgbTextField.autocapitalizationType = .allCharacters
        rgbTextField.autocorrectionType = .no
        rgbTextField.addTarget(self,
                               action: #selector(updateSample),
                               for: .editingChanged)

        alphaTextField.borderStyle = .roundedRect
        alphaTextField.autocapitalizationType = .allCharacters
        alphaTextField.autocorrectionType = .no
        alphaTextField.addTarget(self,
                                 action: #selector(updateSample),
                                 for: .editingChanged)

        sampleView.layer.borderWidth = 0.5
        sampleView.layer.borderColor = UIColor.black.cgColor

        updateSample()
    }

    private func layout() {
        contentStackView.addArrangedSubview(UIView())
        contentStackView.addArrangedSubview(sampleView)
        contentStackView.addArrangedSubview(rgbTextField)
        contentStackView.addArrangedSubview(alphaTextField)

        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += sampleView.match(value: 30)
        constraints += rgbTextField.match(.width, value: 100)
        constraints += alphaTextField.match(.width, value: 50)
    }

    @objc private func updateSample() {
        sampleView.backgroundColor = color
    }
}
