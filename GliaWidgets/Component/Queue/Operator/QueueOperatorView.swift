import UIKit

class QueueOperatorView: UIView {
    private let style: QueueOperatorStyle
    private let placeholderImageView = UIImageView()
    private let imageView = UIImageView()
    private var animationView: QueueAnimationView
    private let kImageInset: CGFloat = 10
    private let kImageViewSize = CGSize(width: 80, height: 80)

    init(with style: QueueOperatorStyle) {
        self.style = style
        self.animationView = QueueAnimationView(color: style.animationColor)
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: UIImage?, animated: Bool) {
        UIView.transition(with: imageView,
                          duration: animated ? 0.2 : 0.0,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.imageView.image = image
                          }, completion: nil)
    }

    func startAnimating(animated: Bool) {
        animationView.startAnimating(animated: animated)
    }

    func stopAnimating(animated: Bool) {
        animationView.stopAnimating(animated: animated)
    }

    private func setup() {
        placeholderImageView.image = style.placeholderImage
        placeholderImageView.tintColor = style.placeholderColor
        placeholderImageView.backgroundColor = style.animationColor
        placeholderImageView.clipsToBounds = true
        placeholderImageView.contentMode = .center
        placeholderImageView.layer.cornerRadius = kImageViewSize.width / 2.0

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = kImageViewSize.width / 2.0
    }

    private func layout() {
        addSubview(animationView)
        animationView.autoCenterInSuperview()
        animationView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)

        addSubview(placeholderImageView)
        placeholderImageView.autoCenterInSuperview()
        placeholderImageView.autoSetDimensions(to: kImageViewSize)
        placeholderImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        placeholderImageView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        placeholderImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        placeholderImageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)

        addSubview(imageView)
        imageView.autoMatch(.height, to: .height, of: placeholderImageView)
        imageView.autoMatch(.width, to: .width, of: placeholderImageView)
        imageView.autoAlignAxis(.horizontal, toSameAxisOf: placeholderImageView)
        imageView.autoAlignAxis(.vertical, toSameAxisOf: placeholderImageView)
    }
}
