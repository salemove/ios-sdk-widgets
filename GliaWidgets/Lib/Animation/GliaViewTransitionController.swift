import UIKit

final class GliaViewTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    enum TransitionMode: Int {
        case present, dismiss
    }

    private let duration = 0.4
    private let originCenterPoint: CGPoint
    private let transitionMode: TransitionMode

    init(originCenterPoint: CGPoint, transitionMode: TransitionMode) {
        self.originCenterPoint = originCenterPoint
        self.transitionMode = transitionMode
        super.init()
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionMode == .present {
            presentView(transitionContext: transitionContext)
        } else {
            dismissView(transitionContext: transitionContext)
        }
    }

    private func presentView(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let presentedViewController = transitionContext.viewController(forKey: .to),
              let presentedView = presentedViewController.view else { return }
        let finalFrame = transitionContext.finalFrame(for: presentedViewController)

        containerView.addSubview(presentedView)

        presentedView.frame = finalFrame
        presentedView.center = originCenterPoint
        presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        presentedView.alpha = 0

        UIView.animate(
            withDuration: duration,
            animations: {
                presentedView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                presentedView.transform = .identity
                presentedView.alpha = 1
            },
            completion: { (success: Bool) in
                transitionContext.completeTransition(success)
            }
        )
    }

    private func dismissView(transitionContext: UIViewControllerContextTransitioning) {
        guard let returningView = transitionContext.view(forKey: .from) else { return }

        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                returningView.center = self?.originCenterPoint ?? .zero
                returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningView.alpha = 0
            },
            completion: { success in
                returningView.transform = .identity
                returningView.removeFromSuperview()
                transitionContext.completeTransition(success)
            }
        )
    }
}
