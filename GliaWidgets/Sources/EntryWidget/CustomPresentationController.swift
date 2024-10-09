import UIKit

final class CustomPresentationController: UIPresentationController {
    private let height: CGFloat
    private let cornerRadius: CGFloat
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.13)
        return view
    }()

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        height: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.height = height
        self.cornerRadius = cornerRadius
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dimmingViewTapped)
        )
        dimmingView.addGestureRecognizer(tapGesture)
    }

    @objc private func dimmingViewTapped() {
        presentedViewController.dismiss(animated: true)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        let topSafeAreaInset = containerView.safeAreaInsets.top
        let yOffset = containerView.bounds.height - height - (topSafeAreaInset / 2)

        return CGRect(
            x: 0,
            y: yOffset,
            width: containerView.bounds.width,
            height: height + (topSafeAreaInset / 2)
        )
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.layer.cornerRadius = cornerRadius
        presentedView?.layer.masksToBounds = true
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView else { return }
        dimmingView.frame = containerView.bounds
        containerView.insertSubview(dimmingView, at: 0)
        dimmingView.alpha = 0
        presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }
        )
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }
        )
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}
