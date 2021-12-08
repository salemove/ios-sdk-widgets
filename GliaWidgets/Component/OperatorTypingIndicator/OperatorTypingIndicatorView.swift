import UIKit
import Lottie

final class OperatorTypingIndicatorView: UIView {
    override var isHidden: Bool {
        didSet {
            if isHidden {
                animationView.stop()
            } else {
                animationView.play()
            }
        }
    }
    private let style: OperatorTypingIndicatorStyle
    private let animationView = AnimationView()
    private let backgroundView = UIView()
    private let kViewSize = CGSize(width: 28, height: 28)
    private let kLeftInset: CGFloat = 10

    init(style: OperatorTypingIndicatorStyle) {
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
        let animation = Animation.named(
            "operator-typing-indicator",
            bundle: Bundle(for: OperatorTypingIndicatorView.self)
        )
        animationView.animation = animation
        animationView.backgroundBehavior = .pauseAndRestore

        let keypath = AnimationKeypath(
            keys: ["**", "Fill 1", "Color"]
        )
        let colorValueProvider = ColorValueProvider(style.color.lottieColorValue)
        animationView.setValueProvider(colorValueProvider, keypath: keypath)

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
    }

    private func layout() {
        addSubview(animationView)
        animationView.autoSetDimensions(to: kViewSize)
        animationView.autoPinEdge(toSuperviewEdge: .left, withInset: kLeftInset)
    }
}
