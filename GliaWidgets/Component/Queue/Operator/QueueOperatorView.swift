import UIKit

class QueueOperatorView: UIView {
    let imageView: UserImageView

    private let style: QueueOperatorStyle
    private var animationView: QueueAnimationView
    private let kImageInset: CGFloat = 10
    private let kImageViewSize = CGSize(width: 80, height: 80)

    init(with style: QueueOperatorStyle) {
        self.style = style
        self.animationView = QueueAnimationView(color: style.animationColor)
        self.imageView = UserImageView(with: style.operatorImage)
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating(animated: Bool) {
        animationView.startAnimating(animated: animated)
    }

    func stopAnimating(animated: Bool) {
        animationView.stopAnimating(animated: animated)
    }

    private func setup() {}

    private func layout() {
        addSubview(animationView)
        animationView.autoCenterInSuperview()
        animationView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)

        addSubview(imageView)
        imageView.autoSetDimensions(to: kImageViewSize)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoCenterInSuperview()
    }
}
