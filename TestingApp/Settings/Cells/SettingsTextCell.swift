import UIKit

class SettingsTextCell: SettingsCell {
    let textField = UITextField()
    var button: UIButton?

    init(
        title: String,
        text: String,
        isRequired: Bool = false,
        extraButton: ExtraButton? = nil
    ) {
        textField.text = text
        if let extraButton {
            self.button = .init(type: .system)
            self.button?.setTitle(extraButton.title, for: .normal)
            self.button?.addTarget(extraButton, action: #selector(extraButton.onTouchUpInside), for: .touchUpInside)
        }
        self.extraButton = extraButton
        self.isRequired = isRequired

        super.init(title: title)

        if isRequired {
            let attributedString = NSMutableAttributedString(string: "\(title) *")
            attributedString.setAttributes([.foregroundColor: UIColor.red.cgColor], range: .init(location: attributedString.length - 1, length: 1))
            titleLabel.attributedText = attributedString
        }
        setup()
        layout()
    }

    // MARK: - Private

    private let extraButton: ExtraButton?
    private let isRequired: Bool

    private func setup() {
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        if let button {
            addSubview(button)
        }
    }

    private func layout() {
        contentStackView.addArrangedSubview(textField)
        if let button {
            contentStackView.addArrangedSubview(button)
        }
    }
}

extension SettingsTextCell {
    class ExtraButton {
        let title: String
        let tap: () -> Void

        init(title: String, tap: @escaping () -> Void) {
            self.title = title
            self.tap = tap
        }

        @objc func onTouchUpInside() {
            tap()
        }
    }
}
