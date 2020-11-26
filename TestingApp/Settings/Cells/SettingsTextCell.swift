import UIKit

class SettingsTextCell: SettingsCell {
    let textField = UITextField()

    public init(title: String, text: String) {
        textField.text = text
        super.init(title: title)
        setup()
        layout()
    }

    private func setup() {
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
    }

    private func layout() {
        contentView.addSubview(textField)
        textField.autoSetDimension(.width, toSize: 250)
        textField.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 10)
        textField.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        textField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20),
                                               excludingEdge: .left)
    }
}
