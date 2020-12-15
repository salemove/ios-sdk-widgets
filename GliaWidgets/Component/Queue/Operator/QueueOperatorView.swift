import UIKit

class QueueOperatorView: UIView {
    let imageView: UserImageView

    private let style: QueueOperatorStyle
    private var animationView: QueueAnimationView?
    private var heightLayoutConstraint: NSLayoutConstraint!
    private var widthLayoutConstraint: NSLayoutConstraint!
    private let kImageInset: CGFloat = 10
    private let kImageViewSize = CGSize(width: 80, height: 80)
    private let kAnimationViewSize: CGFloat = 142

    init(with style: QueueOperatorStyle) {
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

        let animationView = QueueAnimationView(color: style.animationColor,
                                               size: kAnimationViewSize)
        self.animationView = animationView

        heightLayoutConstraint.constant = kAnimationViewSize
        widthLayoutConstraint.constant = kAnimationViewSize

        insertSubview(animationView, at: 0)
        animationView.autoPinEdgesToSuperviewEdges()
        animationView.startAnimating()
    }

    func stopAnimating(animated: Bool) {
        heightLayoutConstraint.constant = kImageViewSize.height
        widthLayoutConstraint.constant = kImageViewSize.width
        animationView?.removeFromSuperview()
        animationView = nil
    }

    private func setup() {}

    private func layout() {
        heightLayoutConstraint = autoSetDimension(.height, toSize: kImageViewSize.height)
        widthLayoutConstraint = autoSetDimension(.width, toSize: kImageViewSize.width)

        addSubview(imageView)
        imageView.autoSetDimensions(to: kImageViewSize)
        imageView.autoCenterInSuperview()
    }
}
