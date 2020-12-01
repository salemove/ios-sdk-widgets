import UIKit

class ChatOperatorImageView: UIView {
    var isAnimating: Bool = false {
        didSet {
            isAnimating
                ? startAnimating()
                : stopAnimating()
        }
    }

    private let style: ChatOperatorImageStyle
    private let placeholderImageView = UIImageView()
    private let imageView = UIImageView()
    private var animationView: AnimationView?
    private let kImageInset: CGFloat = 10
    private let kImageViewSize = CGSize(width: 80, height: 80)

    init(with style: ChatOperatorImageStyle) {
        self.style = style
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

    private func startAnimating() {
        guard animationView == nil else { return }

        let animationView = AnimationView(color: style.animationColor,
                                          baseSize: kImageViewSize)
        self.animationView = animationView

        insertSubview(animationView, belowSubview: placeholderImageView)
        animationView.autoPinEdgesToSuperviewEdges()

        animationView.startAnimating()
    }

    private func stopAnimating() {
        animationView?.stopAnimating()
        animationView?.removeFromSuperview()
        animationView = nil
    }
}

private class AnimationView: UIView {
    private let color: UIColor
    private let baseSize: CGSize
    private let circles = [UIView(), UIView(), UIView()]
    private let sizeIncrements: [CGFloat] = [62.0, 34.0, 0.0]
    private let alphas: [CGFloat] = [0.3, 0.6, 1.0]

    init(color: UIColor, baseSize: CGSize) {
        self.color = color
        self.baseSize = baseSize
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        circles.enumerated().forEach {
            let circle = $0.element
            let sizeIncrement = self.sizeIncrements[$0.offset]
            let alpha = self.alphas[$0.offset]
            let size = CGSize(width: self.baseSize.width + sizeIncrement,
                              height: self.baseSize.height + sizeIncrement)
            circle.frame.size = size
            circle.layer.cornerRadius = size.width / 2.0
            circle.backgroundColor = color.withAlphaComponent(alpha)
        }
    }

    private func layout() {
        circles.enumerated().forEach {
            let circle = $0.element
            self.addSubview(circle)
            circle.autoCenterInSuperview()
            circle.autoSetDimensions(to: circle.frame.size)
            circle.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
            circle.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
            circle.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
            circle.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
        }
    }

    func startAnimating() {

    }

    func stopAnimating() {

    }
}
