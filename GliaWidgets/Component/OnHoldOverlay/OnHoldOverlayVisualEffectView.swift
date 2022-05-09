import UIKit

final class OnHoldOverlayVisualEffectView: UIVisualEffectView {
    private var animator = UIViewPropertyAnimator(
        duration: 1,
        curve: .linear
    )

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        effect = nil
        animator.stopAnimation(true)
        animator.addAnimations { [weak self] in
            self?.effect = UIBlurEffect(style: .regular)
        }
        animator.fractionComplete = 0.1
    }

    deinit {
        animator.stopAnimation(true)
    }
}
