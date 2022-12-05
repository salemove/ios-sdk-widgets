import UIKit
import PureLayout

final class OnHoldOverlayView: UIView {
    private let style: OnHoldOverlayStyle
    private let blurEffectView = OnHoldOverlayVisualEffectView()
    private let imageView = UIImageView()

    private var gradientLayer: CAGradientLayer?

    init(style: OnHoldOverlayStyle) {
        self.style = style

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
        addSubview(blurEffectView)
        blurEffectView.autoPinEdgesToSuperviewEdges()

        addSubview(imageView)
        imageView.autoCenterInSuperview()
        imageView.autoSetDimensions(to: style.imageSize)
    }
}
