import UIKit

class ConnectAnimationView: UIView {
    private let color: UIColor
    private let size: CGFloat
    private let replicatorLayer = CAReplicatorLayer()
    private let circleLayer = CAShapeLayer()
    private let kAnimationDuration: Double = 2.5
    private let kAnimationName = "animation"

    private var animationBounds: CGRect {
        return CGRect(origin: .zero,
                      size: CGSize(width: size, height: size))
    }

    init(color: UIColor, size: CGFloat) {
        self.color = color
        self.size = size
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        addAnimation()
    }

    func stopAnimating(animated: Bool) {
        removeAnimation()
    }

    private func setup() {
        replicatorLayer.instanceCount = 2
        replicatorLayer.instanceDelay = 0.3
        replicatorLayer.frame = animationBounds
        replicatorLayer.position = CGPoint(x: animationBounds.midX,
                                           y: animationBounds.midY)

        circleLayer.opacity = 0.0
        circleLayer.fillColor = color.cgColor
        circleLayer.path = UIBezierPath(ovalIn: animationBounds).cgPath
        circleLayer.frame = animationBounds
        circleLayer.position = CGPoint(x: animationBounds.midX,
                                       y: animationBounds.midY)
    }

    private func layout() {
        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            autoSetDimensions(to: CGSize(width: size, height: size))
        }

        replicatorLayer.addSublayer(circleLayer)
        layer.addSublayer(replicatorLayer)
    }

    private func addAnimation() {
        let animation = makeAnimation(duration: kAnimationDuration)
        circleLayer.add(animation, forKey: kAnimationName)
    }

    private func removeAnimation() {
        circleLayer.removeAnimation(forKey: kAnimationName)
    }

    private func makeAnimation(duration: Double) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = duration
        animationGroup.repeatCount = .infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        animationGroup.animations = [
            makeScaleAnimation(duration: duration),
            makeOpacityAnimation(duration: duration)
        ]
        return animationGroup
    }

    private func makeScaleAnimation(duration: Double) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fillMode = CAMediaTimingFillMode.backwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        scaleAnimation.fromValue = NSNumber(value: 0.0)
        scaleAnimation.toValue = NSNumber(value: 1.0)
        scaleAnimation.duration = duration
        scaleAnimation.isRemovedOnCompletion = false
        return scaleAnimation
    }

    private func makeOpacityAnimation(duration: Double) -> CAKeyframeAnimation {
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.fillMode = CAMediaTimingFillMode.backwards
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnimation.values = [0.5, 0.8, 0]
        opacityAnimation.keyTimes = [0, 0.5, 1]
        opacityAnimation.duration = duration
        opacityAnimation.isRemovedOnCompletion = false
        return opacityAnimation
    }
}
