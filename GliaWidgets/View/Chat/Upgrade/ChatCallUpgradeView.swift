import UIKit

class ChatCallUpgradeView: UIView {
    var style: ChatCallUpgradeStyle {
        didSet { update(with: style) }
    }

    private let durationProvider: ValueProvider<Int>
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let textLabel = UILabel()
    private let durationLabel = UILabel()
    private let kContentInsets = UIEdgeInsets(top: 8, left: 44, bottom: 8, right: 44)

    init(with style: ChatCallUpgradeStyle, durationProvider: ValueProvider<Int>) {
        self.style = style
        self.durationProvider = durationProvider
        super.init(frame: .zero)
        setup()
        layout()
    }

    deinit {
        durationProvider.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        update(with: style)

        durationProvider.addObserver(self) { duration, _ in
            self.durationLabel.text = duration.asDurationString
        }
    }

    private func update(with style: ChatCallUpgradeStyle) {
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
        textLabel.textAlignment = .center

        durationLabel.text = durationProvider.value.asDurationString
        durationLabel.font = style.durationFont
        durationLabel.textColor = style.durationColor
        durationLabel.textAlignment = .center
    }

    private func layout() {
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets)

        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))

        let iconWrapper = UIView()
        iconWrapper.addSubview(iconImageView)
        iconImageView.autoPinEdge(toSuperviewEdge: .top)
        iconImageView.autoPinEdge(toSuperviewEdge: .bottom)
        iconImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        iconImageView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        iconImageView.autoAlignAxis(toSuperviewAxis: .vertical)

        stackView.addArrangedSubviews(
            [iconWrapper, textLabel, durationLabel]
        )
    }
}
