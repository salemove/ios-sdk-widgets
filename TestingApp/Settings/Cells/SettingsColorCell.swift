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
        contentView.addSubview(sampleView)
        sampleView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += sampleView.match(value: 30)
        constraints += sampleView.leadingAnchor.constraint(
            greaterThanOrEqualTo: titleLabel.trailingAnchor,
            constant: 20
        )
        constraints += sampleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)

        contentView.addSubview(rgbTextField)
        rgbTextField.translatesAutoresizingMaskIntoConstraints = false
        constraints += rgbTextField.match(.width, value: 100)
        constraints += rgbTextField.layoutInSuperview(
            edges: .vertical,
            insets: .init(top: 10, left: 0, bottom: 10, right: 0)
        )
        constraints += rgbTextField.leadingAnchor.constraint(
            equalTo: sampleView.trailingAnchor,
            constant: 10
        )

        contentView.addSubview(alphaTextField)
        alphaTextField.translatesAutoresizingMaskIntoConstraints = false
        constraints += alphaTextField.match(.width, value: 50)
        constraints += alphaTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        constraints += alphaTextField.leadingAnchor.constraint(
            equalTo: rgbTextField.trailingAnchor,
            constant: 10
        )
        constraints += alphaTextField.layoutInSuperview(
            edges: .trailing,
            insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20)
        )
    }

    @objc private func updateSample() {
        sampleView.backgroundColor = color
    }
}
