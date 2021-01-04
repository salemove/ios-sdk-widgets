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
        textField.autoMatch(.width, to: .width, of: contentView, withMultiplier: 0.7)
        textField.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 10, relation: .greaterThanOrEqual)
        textField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20),
                                               excludingEdge: .left)
    }
}
