import UIKit

final class OnHoldOverlayView: UIView {
    private let style: OnHoldOverlayStyle
    private let blurEffectView: OnHoldOverlayVisualEffectView
    private let imageView = UIImageView()

    private var gradientLayer: CAGradientLayer?

    init(
        environment: Environment,
        style: OnHoldOverlayStyle
    ) {
        self.style = style
        self.blurEffectView = OnHoldOverlayVisualEffectView(environment: .init(gcd: environment.gcd))

        super.init(frame: .zero)

        layout()
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer?.frame = bounds
    }

    private func setup() {
        imageView.image = style.image.withRenderingMode(.alwaysTemplate)
        switch style.imageColor {
        case .fill(let color):
            imageView.tintColor = color
        case .gradient(let colors):
            imageView.makeGradientBackground(colors: colors)
        }

        switch style.backgroundColor {
        case .fill(let color):
            backgroundColor = color
        case .gradient(let colors):
            gradientLayer = makeGradientBackground(colors: colors)
        }
    }

    private func layout() {
        var constraints = [NSLayoutConstraint](); defer { constraints.activate() }
        addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        constraints += blurEffectView.layoutInSuperview()

        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        constraints += imageView.layoutInSuperviewCenter()
        constraints += imageView.match(.width, value: style.imageSize.width)
        constraints += imageView.match(.height, value: style.imageSize.height)
    }
}

extension OnHoldOverlayView {
    struct Environment {
        let gcd: GCD
    }
}
