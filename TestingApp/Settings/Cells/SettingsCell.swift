import UIKit

class SettingsCell: UITableViewCell {
    let titleLabel = UILabel()

    init(title: String) {
        titleLabel.text = title
        super.init(style: .default, reuseIdentifier: nil)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = .darkGray
        titleLabel.numberOfLines = 0
    }

    private func layout() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        constraints += titleLabel.layoutInSuperview(
            edges: .vertical,
            insets: insets
        )
        constraints += titleLabel.layoutInSuperview(
            edges: .leading,
            insets: insets
        )
    }
}
