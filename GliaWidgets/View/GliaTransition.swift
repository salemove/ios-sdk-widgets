import UIKit

final class GliaTransition: NSObject {
    private var circle = UIView()
    var startingPoint = CGPoint.zero {
        didSet {
            circle.center = startingPoint
        }
    }
    private let duration = 0.4

    enum TransitionMode: Int {
        case present, dismiss, pop
    }

    var transitionMode: TransitionMode = .present
}

// MARK: - UIViewControllerAnimatedTransitioning

extension GliaTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
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

        if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
            let viewCenter = presentedView.center
            let viewSize = presentedView.frame.size

            circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
            circle.layer.cornerRadius = circle.frame.size.height / 2
            circle.center = startingPoint
            circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            containerView.addSubview(circle)

            presentedView.center = startingPoint
            presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            presentedView.alpha = 0
            containerView.addSubview(presentedView)

            UIView.animate(withDuration: duration, animations: {
                self.circle.transform = CGAffineTransform.identity
                presentedView.transform = CGAffineTransform.identity
                presentedView.alpha = 1
                presentedView.center = viewCenter
            }, completion: { (success: Bool) in
                transitionContext.completeTransition(success)
            })
        }
    }

    private func dismissView(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from

        if let returningView = transitionContext.view(forKey: transitionModeKey) {
            let viewCenter = returningView.center
            let viewSize = returningView.frame.size

            circle.frame = frameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
            circle.layer.cornerRadius = circle.frame.size.height / 2
            circle.center = startingPoint

            UIView.animate(withDuration: duration, animations: {
                self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningView.center = self.startingPoint
                returningView.alpha = 0

                if self.transitionMode == .pop {
                    containerView.insertSubview(returningView, belowSubview: returningView)
                    containerView.insertSubview(self.circle, belowSubview: returningView)
                }
            }, completion: { (success: Bool) in
                returningView.center = viewCenter
                returningView.removeFromSuperview()
                self.circle.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }

    private func frameForCircle (withViewCenter viewCenter: CGPoint, size viewSize: CGSize, startPoint: CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)

        let offsetVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offsetVector, height: offsetVector)

        return CGRect(origin: CGPoint.zero, size: size)
    }
}
