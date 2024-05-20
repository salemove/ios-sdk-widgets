import UIKit

final class OnHoldOverlayVisualEffectView: UIVisualEffectView {
    private var animator = UIViewPropertyAnimator(
        duration: 1,
        curve: .linear
    )
    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
        super.init(effect: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        environment.gcd.mainQueue.async {
            self.effect = nil
            self.animator.stopAnimation(true)
            self.animator.addAnimations { [weak self] in
                self?.effect = UIBlurEffect(style: .regular)
            }
            self.animator.fractionComplete = 0.1
        }
    }

    deinit {
        animator.stopAnimation(true)
    }
}

extension OnHoldOverlayVisualEffectView {
    struct Environment {
        let gcd: GCD
    }
}
