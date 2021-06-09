import UIKit

class BubbleTransitionAnimationController: NSObject {
    enum TransitionType {
        case present
        case dismiss
    }

    private let duration: Double
    private let transitionType: TransitionType

    init(duration: Double, transitionType: TransitionType) {
        self.duration = duration
        self.transitionType = transitionType
    }
}

extension BubbleTransitionAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(exactly: duration) ?? 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        switch transitionType {
        case .present:
            transitionContext.containerView.addSubview(toViewController.view)
            presentAnimation(with: transitionContext, viewToAnimate: toViewController.view)
        case .dismiss:
            dismissAnimation(with: transitionContext, viewToAnimate: fromViewController.view)
        }
    }

    private func presentAnimation(
        with transitionContext: UIViewControllerContextTransitioning,
        viewToAnimate: UIView
    ) {
        print("*** PRESENT")
        let duration = transitionDuration(using: transitionContext)

        viewToAnimate.clipsToBounds = true
        viewToAnimate.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseIn,
            animations: { viewToAnimate.transform = .identity },
            completion: { _ in transitionContext.completeTransition(true) }
        )
    }

    private func dismissAnimation(
        with transitionContext: UIViewControllerContextTransitioning,
        viewToAnimate: UIView
    ) {
        print("*** DISMISS")
        let duration = transitionDuration(using: transitionContext)

        viewToAnimate.transform = .identity
        viewToAnimate.alpha = 1

        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: { viewToAnimate.transform = CGAffineTransform(scaleX: 0, y: 0) },
            completion: { _ in transitionContext.completeTransition(true) }
        )
    }
}
