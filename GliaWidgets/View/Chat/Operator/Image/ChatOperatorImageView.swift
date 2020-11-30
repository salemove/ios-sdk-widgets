import UIKit

class ChatOperatorImageView: UIView {
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue == nil
                ? style.placeholderImage
                : newValue
        }
    }
    var isAnimating: Bool = false {
        didSet {
            isAnimating
                ? startAnimating()
                : stopAnimating()
        }
    }

    private let style: ChatOperatorImageStyle
    private let imageView = UIImageView()
    private var animationView: AnimationView?
    private let kImageInset: CGFloat = 10
    private let kImageSize = CGSize(width: 80, height: 80)

    init(with style: ChatOperatorImageStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.image = nil
        imageView.tintColor = style.placeholderColor
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.layer.cornerRadius = kImageSize.width / 2.0

        imageView.backgroundColor = .red
    }

    private func layout() {
        let imageSize = CGSize(width: kImageSize.width - kImageInset,
                               height: kImageSize.height - kImageInset)

        addSubview(imageView)
        //imageView.autoSetDimensions(to: imageSize)
        imageView.autoCenterInSuperview()
    }

    private func startAnimating() {
        guard animationView == nil else { return }

        let animationView = AnimationView(color: style.animationColor,
                                          baseSize: kImageSize)
        self.animationView = animationView

        insertSubview(animationView, belowSubview: imageView)
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
            print(size)
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
