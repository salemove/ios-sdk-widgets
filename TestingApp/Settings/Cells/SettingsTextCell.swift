import UIKit

class SettingsTextCell: SettingsCell {
    let textField = UITextField()

    init(title: String, text: String) {
        textField.text = text
        super.init(title: title)
        setup()
        layout()
    }

    private func setup() {
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
    }

    private func layout() {
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        constraints += textField.widthAnchor.constraint(
            equalTo: contentView.widthAnchor,
            multiplier: 0.7
        )
        constraints += textField.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 10)
        let insets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20)
        constraints += textField.layoutInSuperview(edges: .vertical, insets: insets)
        constraints += textField.layoutInSuperview(edges: .trailing, insets: insets)
    }
}
