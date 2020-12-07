import UIKit

class PoweredBy: UIView {
    var color: UIColor = Color.baseShade {
        didSet { setColor() }
    }

    private let label = UILabel()
    private let logoImageView = UIImageView()
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

        logoImageView.image = Asset.gliaLogo.image

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.addArrangedSubviews([
            label,
            logoImageView
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
    }

    private func setColor() {
        label.textColor = color.withAlphaComponent(0.5)
        logoImageView.tintColor = color.withAlphaComponent(1.0)
    }
}
