import UIKit
import PureLayout

final class OnHoldOverlayView: UIView {
    private let style: OnHoldOverlayStyle
    private let blurEffectView = OnHoldOverlayVisualEffectView()
    private let imageView = UIImageView()

    init(style: OnHoldOverlayStyle) {
        self.style = style

        super.init(frame: .zero)

        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.image = style.image.withRenderingMode(.alwaysTemplate)
        switch style.imageColor {
        case .fill(let color):
            imageView.tintColor = color
        case .gradient(let colors):
            imageView.makeGradientBackground(colors: colors).frame = imageView.bounds
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
