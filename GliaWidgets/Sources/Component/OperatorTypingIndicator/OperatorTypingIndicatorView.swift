import UIKit

private let animationDuration: CFTimeInterval = 0.5

final class OperatorTypingIndicatorView: BaseView {
    private lazy var dotLeadingView = DotView(
        color: style.color,
        duration: animationDuration,
        beginTime: 0
    )
    private lazy var dotMiddleView = DotView(
        color: style.color,
        duration: animationDuration,
        beginTime: animationDuration / 2
    )
    private lazy var dotTrailingView = DotView(
        color: style.color,
        duration: animationDuration,
        beginTime: animationDuration
    )

    private lazy var stack = UIStackView.make(.horizontal, spacing: 3)(
        dotLeadingView,
        dotMiddleView,
        dotTrailingView
    )

    var accessibilityProperties: AccessibilityProperties {
        didSet {
            updateAccessibility()
        }
    }

    private let style: OperatorTypingIndicatorStyle

    init(
        accessibilityProperties: AccessibilityProperties,
        style: OperatorTypingIndicatorStyle
    ) {
        self.accessibilityProperties = accessibilityProperties
        self.style = style
        super.init()
    }

    required init() { fatalError("init() has not been implemented") }

    override func setup() {
        super.setup()

        addSubview(stack)
    }

    override func defineLayout() {
        super.defineLayout()

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            dotLeadingView.widthAnchor.constraint(equalTo: dotMiddleView.widthAnchor),
            dotMiddleView.widthAnchor.constraint(equalTo: dotTrailingView.widthAnchor)
        ])
    }

    private func updateAccessibility() {
        accessibilityLabel = style.accessibility.label.withOperatorName(accessibilityProperties.operatorName)
    }
}

extension OperatorTypingIndicatorView {
    final class DotView: BaseView {
        private let color: UIColor

        private var shape: CAShapeLayer?

        private var positions: (top: CGRect, bottom: CGRect)?
        private let beginTime: CFTimeInterval
        private let duration: CFTimeInterval

        init(
            color: UIColor,
            duration: CFTimeInterval,
            beginTime: CFTimeInterval
        ) {
            self.color = color
            self.beginTime = beginTime
            self.duration = duration
            super.init()
        }

        required init() { fatalError("init() has not been implemented") }

        override func draw(_ rect: CGRect) {
            super.draw(rect)

            shape?.removeFromSuperlayer()

            let size = min(rect.width, rect.height)
            let rect = CGRect(x: 0, y: 0, width: size, height: size)
            shape = CAShapeLayer()
            // Flips shape to start animation from correct possition.
            shape?.transform = CATransform3DScale(shape?.transform ?? .init(), 1, -1, 1)
            shape?.path = UIBezierPath(
                roundedRect: rect,
                cornerRadius: size / 2
            ).cgPath
            shape?.fillColor = color.cgColor
            if let shape {
                layer.addSublayer(shape)
            }
            positions = (
                CGRect(x: 0, y: size, width: size, height: size),
                rect
            )
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            startAnimation()
        }

        private func startAnimation() {
            guard let shape, let positions else { return }

            let positionAnimation = CASpringAnimation(keyPath: "position")
            setupAnimation(
                animation: positionAnimation,
                from: positions.bottom,
                to: positions.top
            )
            let colorAnimation = CABasicAnimation(keyPath: "fillColor")
            setupAnimation(
                animation: colorAnimation,
                from: color.cgColor,
                to: color.withAlphaComponent(0.5).cgColor
            )
            shape.add(positionAnimation, forKey: nil)
            shape.add(colorAnimation, forKey: nil)
        }

        private func setupAnimation(
            animation: CABasicAnimation,
            from: Any?,
            to: Any?
        ) {
            animation.fromValue = from
            animation.toValue = to
            animation.duration = duration
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + beginTime
        }
    }
}

extension OperatorTypingIndicatorView {
    struct AccessibilityProperties {
        var operatorName: String
    }
}
