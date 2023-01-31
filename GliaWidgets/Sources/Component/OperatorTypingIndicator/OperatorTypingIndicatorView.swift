import UIKit
import Lottie

final class OperatorTypingIndicatorView: BaseView {
    override var isHidden: Bool {
        didSet {
            isHidden ? animationView.stop() : animationView.play()
        }
    }
    private let style: OperatorTypingIndicatorStyle
    private let animationView = AnimationView()
    private let kViewSize = CGSize(width: 28, height: 28)
    private let kLeftInset: CGFloat = 10
    private let bundleManaging: BundleManaging
    var accessibilityProperties: AccessibilityProperties {
        didSet {
            updateAccessibility()
        }
    }

    init(
        style: OperatorTypingIndicatorStyle,
        bundleManaging: BundleManaging = .live,
        accessibilityProperties: AccessibilityProperties
    ) {
        self.style = style
        self.bundleManaging = bundleManaging
        self.accessibilityProperties = accessibilityProperties
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func setup() {
        super.setup()
        let animation = Animation.named(
            "operator-typing-indicator",
            bundle: bundleManaging.current()
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
        isAccessibilityElement = true
        updateAccessibility()
    }

    override func defineLayout() {
        super.defineLayout()
        addSubview(animationView)
        animationView.autoSetDimensions(to: kViewSize)
        animationView.autoPinEdge(toSuperviewEdge: .leading, withInset: kLeftInset)
        animationView.autoPinEdge(toSuperviewEdge: .top)
        animationView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func updateAccessibility() {
        accessibilityLabel = style.accessibility.label.withOperatorName(accessibilityProperties.operatorName)
    }
}

extension OperatorTypingIndicatorView {
    struct AccessibilityProperties {
        var operatorName: String
    }
}
