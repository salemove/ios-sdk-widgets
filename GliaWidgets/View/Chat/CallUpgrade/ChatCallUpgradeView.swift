import UIKit

class ChatCallUpgradeView: UIView {
    private let style: ChatCallUpgradeStyle
    private let durationProvider: Provider<Int>
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let textLabel = UILabel()
    private let durationLabel = UILabel()
    private let kContentInsets = UIEdgeInsets(top: 8, left: 44, bottom: 8, right: 44)

    init(with style: ChatCallUpgradeStyle, durationProvider: Provider<Int>) {
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

        durationLabel.text = durationProvider.value.asDurationString
        durationLabel.font = style.durationFont
        durationLabel.textColor = style.textColor

        durationProvider.addObserver(self) { duration, _ in
            self.durationLabel.text = duration.asDurationString
        }
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
