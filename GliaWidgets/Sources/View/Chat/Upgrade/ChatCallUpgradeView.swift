import UIKit

class ChatCallUpgradeView: UIView {
    var style: ChatCallUpgradeStyle {
        didSet { update(with: style) }
    }

    private let duration: ObservableValue<Int>
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let textLabel = UILabel()
    private let durationLabel = UILabel()
    private let kContentInsets = UIEdgeInsets(top: 8, left: 44, bottom: 8, right: 44)

    init(with style: ChatCallUpgradeStyle, duration: ObservableValue<Int>) {
        self.style = style
        self.duration = duration
        super.init(frame: .zero)
        setup()
        layout()
    }

    deinit {
        duration.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        update(with: style)

        duration.addObserver(self) { [weak self] duration, _ in
            self?.durationLabel.text = duration.asDurationString
        }
    }

    private func update(with style: ChatCallUpgradeStyle) {
        contentView.layer.cornerRadius = style.cornerRadius
        contentView.layer.borderWidth = style.borderWidth
        contentView.layer.borderColor = style.borderColor.cgColor

        stackView.axis = .vertical
        stackView.spacing = 8

        iconImageView.image = style.icon
        iconImageView.tintColor = style.iconColor

        textLabel.text = style.text
        textLabel.font = style.textFont
        textLabel.numberOfLines = 0
        textLabel.textColor = style.textColor
        textLabel.textAlignment = .center

        durationLabel.text = duration.value.asDurationString
        durationLabel.font = style.durationFont
        durationLabel.textColor = style.durationColor
        durationLabel.textAlignment = .center
        durationLabel.accessibilityHint = style.accessibility.durationTextHint
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: durationLabel
        )
    }

    private func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        constraints += contentView.layoutInSuperview(insets: kContentInsets)

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        constraints += stackView.layoutInSuperview(insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))

        let iconWrapper = UIView()
        iconWrapper.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += iconImageView.layoutInSuperview(edges: .vertical)
        constraints += iconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: iconWrapper.leadingAnchor)
        constraints += iconImageView.trailingAnchor.constraint(lessThanOrEqualTo: iconWrapper.trailingAnchor)
        constraints += iconImageView.centerXAnchor.constraint(equalTo: iconWrapper.centerXAnchor)

        stackView.addArrangedSubviews(
            [iconWrapper, textLabel, durationLabel]
        )
    }
}
