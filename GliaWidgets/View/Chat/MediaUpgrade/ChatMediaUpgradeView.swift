import UIKit

class ChatMediaUpgradeView: UIView {
    private let style: ChatMediaUpgradeStyle
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let textLabel = UILabel()
    private let durationLabel = UILabel()
    private let kContentInsets = UIEdgeInsets(top: 8, left: 44, bottom: 8, right: 44)

    init(with style: ChatMediaUpgradeStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = style.borderColor.cgColor

        stackView.axis = .vertical
        stackView.spacing = 8

        iconImageView.image = style.icon
        iconImageView.tintColor = style.iconColor

        textLabel.text = style.text
        textLabel.font = style.textFont
        textLabel.textColor = style.textColor

        durationLabel.font = style.durationFont
        durationLabel.textColor = style.textColor
    }

    private func layout() {
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))

        let iconWrapper = UIView()
        iconWrapper.addSubview(iconImageView)
        iconImageView.autoCenterInSuperview()

        stackView.addArrangedSubviews(
            [iconWrapper, textLabel, durationLabel]
        )
    }
}
