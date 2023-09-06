import UIKit

class SettingsCell: UITableViewCell {
    lazy var contentStackView = UIStackView.make(.horizontal, spacing: 8)(
        titleLabel
    )
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
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.minimumScaleFactor = 0.8
    }

    private func layout() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        constraints += contentStackView.layoutInSuperview(insets: insets)

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
