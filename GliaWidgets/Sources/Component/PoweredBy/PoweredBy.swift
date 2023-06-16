import UIKit

class PoweredBy: UIView {
    var color: UIColor = Color.baseShade {
        didSet { setColor() }
    }

    private let label = UILabel()
    private let logoImageView = UIImageView()
    private let stackView = UIStackView()
    private let style: PoweredByStyle

    init(style: PoweredByStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        label.text = style.text
        label.font = style.font
        label.accessibilityLabel = "Powered By Glia"
        setFontScalingEnabled(
            style.accessibility.isFontScalingEnabled,
            for: label
        )

        logoImageView.image = Asset.gliaLogo.image

        let size = logoImageView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        logoImageView.heightAnchor.constraint(
            equalTo: logoImageView.widthAnchor,
            multiplier: size.height / size.width
        ).isActive = true

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.addArrangedSubviews([
            label,
            logoImageView
        ])

        setColor()
    }

    private func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        constraints += stackView.layoutInSuperviewCenter()
        constraints += stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
        constraints += stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        constraints += stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor)
        constraints += stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
    }

    private func setColor() {
        label.textColor = color.withAlphaComponent(0.5)
        logoImageView.tintColor = color.withAlphaComponent(1.0)
    }
}
