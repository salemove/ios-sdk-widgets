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

/*private class AnimationView: UIView {
    private let color: UIColor
    private let circles = [UIView(), UIView(), UIView()]
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private let kInsets: [CGFloat] = [0.0, 14.0, 31.0]
    private let kAlphas: [CGFloat] = [0.3, 0.6, 1.0]
    private let kInactiveSize = CGSize(width: 80, height: 80)
    private let kActiveSize = CGSize(width: 142, height: 142)

    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0) {
            self.widthConstraint.constant = self.kActiveSize.width
            self.heightConstraint.constant = self.kActiveSize.height
            self.layoutIfNeeded()
            self.updateCornerRadiuses()
        } completion: { _ in
            self.alpha = 1.0
        }
    }

    func stopAnimating(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0.0) {
            self.widthConstraint.constant = self.kInactiveSize.width
            self.heightConstraint.constant = self.kInactiveSize.width
            self.layoutIfNeeded()
        } completion: { _ in
            self.alpha = 0.0
        }
    }

    private func setup() {
        alpha = 0.0

        circles.enumerated().forEach {
            let circle = $0.element
            let alpha = self.kAlphas[$0.offset]
            circle.backgroundColor = color.withAlphaComponent(alpha)
            circle.layer.frame.size = kInactiveSize
            updateCornerRadiuses()
        }
    }

    private func layout() {
        widthConstraint = autoSetDimension(.width, toSize: kInactiveSize.width)
        heightConstraint = autoSetDimension(.height, toSize: kInactiveSize.height)

        circles.enumerated().forEach {
            let circle = $0.element
            let inset = self.kInsets[$0.offset]
            let insets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            self.addSubview(circle)
            circle.autoCenterInSuperview()
            circle.autoPinEdgesToSuperviewEdges(with: insets)
        }
    }

    private func updateCornerRadiuses() {
        circles.forEach {
            $0.layer.cornerRadius = $0.frame.size.width / 2.0
        }
    }
}
*/
