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
        sampleView.autoSetDimensions(to: CGSize(width: 30, height: 30))
        sampleView.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 20, relation: .greaterThanOrEqual)
        sampleView.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(rgbTextField)
        rgbTextField.autoSetDimension(.width, toSize: 100)
        rgbTextField.autoPinEdge(.left, to: .right, of: sampleView, withOffset: 10)
        rgbTextField.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        rgbTextField.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)

        contentView.addSubview(alphaTextField)
        alphaTextField.autoSetDimension(.width, toSize: 50)
        alphaTextField.autoAlignAxis(toSuperviewAxis: .horizontal)
        alphaTextField.autoPinEdge(.left, to: .right, of: rgbTextField, withOffset: 10)
        alphaTextField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20), excludingEdge: .left)
    }

    @objc private func updateSample() {
        sampleView.backgroundColor = color
    }
}
