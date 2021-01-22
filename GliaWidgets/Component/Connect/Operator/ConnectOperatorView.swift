import UIKit

class ConnectOperatorView: UIView {
    let imageView: UserImageView

    private let style: ConnectOperatorStyle
    private var animationView: ConnectAnimationView?
    private let kImageInset: CGFloat = 10
    private let kImageViewSize = CGSize(width: 80, height: 80)
    private let kAnimationViewSize: CGFloat = 142

    init(with style: ConnectOperatorStyle) {
        self.style = style
        self.imageView = UserImageView(with: style.operatorImage)
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating(animated: Bool) {
        guard animationView == nil else { return }

        let animationView = ConnectAnimationView(color: style.animationColor,
                                               size: kAnimationViewSize)
        self.animationView = animationView

        insertSubview(animationView, at: 0)
        animationView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoCenterInSuperview()
        animationView.startAnimating()
    }

    func stopAnimating(animated: Bool) {
        animationView?.removeFromSuperview()
        animationView = nil
    }

    private func setup() {}

    private func layout() {
        NSLayoutConstraint.autoSetPriority(.defaultHigh) {
            imageView.autoSetDimensions(to: kImageViewSize)
        }

        addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoCenterInSuperview()
    }
}
