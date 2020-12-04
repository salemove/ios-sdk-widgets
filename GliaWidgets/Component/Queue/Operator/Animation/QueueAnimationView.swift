import UIKit

class QueueAnimationView: UIView {
    private let color: UIColor
    private let replicatorLayer = CAReplicatorLayer()
    private let circleLayer = CAShapeLayer()
    private var heightConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    private let kSize: CGFloat = 142
    private let kAnimationDuration: Double = 2.5
    private let kAnimationName = "animation"

    private var activeBounds: CGRect {
        return CGRect(origin: .zero,
                      size: CGSize(width: kSize, height: kSize))
    }

    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0) {
            self.heightConstraint.constant = self.kSize
            self.widthConstraint.constant = self.kSize
            self.layoutIfNeeded()
        } completion: { _ in
            self.addAnimation()
        }
    }

    func stopAnimating(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0.0) {
            self.heightConstraint.constant = 0
            self.widthConstraint.constant = 0
            self.layoutIfNeeded()
        } completion: { _ in
            self.removeAnimation()
        }
    }

    private func setup() {
        replicatorLayer.instanceCount = 2
        replicatorLayer.instanceDelay = 0.3
        replicatorLayer.frame = activeBounds
        replicatorLayer.position = CGPoint(x: activeBounds.midX,
                                           y: activeBounds.midY)

        circleLayer.opacity = 0.0
        circleLayer.fillColor = color.cgColor
        circleLayer.path = UIBezierPath(ovalIn: activeBounds).cgPath
        circleLayer.position = CGPoint(x: activeBounds.midX,
                                       y: activeBounds.midY)
        circleLayer.frame = activeBounds
    }

    private func layout() {
        widthConstraint = autoSetDimension(.width, toSize: 0)
        heightConstraint = autoSetDimension(.height, toSize: 0)

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
