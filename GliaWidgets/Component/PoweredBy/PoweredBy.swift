import UIKit

class PoweredBy: UIView {
    var color: UIColor = Color.baseShade {
        didSet { setColor() }
    }

    private let label = UILabel()
    private let logoNameImageView = UIImageView()
    private let logoIconImageView = UIImageView()
    private let stackView = UIStackView()

    public init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        label.text = L10n.poweredBy
        label.font = Font.regular(12)

        logoNameImageView.image = Asset.logoName.image
        logoIconImageView.image = Asset.logoIcon.image

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.addArrangedSubviews([
            label,
            logoNameImageView,
            logoIconImageView
        ])

        setColor()
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoCenterInSuperview()
        stackView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        stackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)

        stackView.setCustomSpacing(4, after: label)
        stackView.setCustomSpacing(2, after: logoNameImageView)
    }

    private func setColor() {
        label.textColor = color
        logoNameImageView.tintColor = color.withAlphaComponent(1.0)
        logoIconImageView.tintColor = color.withAlphaComponent(1.0)
    }
}
