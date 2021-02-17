import UIKit

class ConnectOperatorView: UIView {
    enum Size {
        case normal
        case large

        var width: CGFloat {
            switch self {
            case .normal:
                return 80
            case .large:
                return 120
            }
        }

        var height: CGFloat {
            switch self {
            case .normal:
                return 80
            case .large:
                return 120
            }
        }
    }

    let imageView: UserImageView

    private let style: ConnectOperatorStyle
    private var animationView: ConnectAnimationView?
    private var size: Size = .normal
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
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

    func setSize(_ size: Size, animated: Bool) {
        self.size = size
        layoutIfNeeded()
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.widthConstraint.constant = size.width
            self.heightConstraint.constant = size.height
            self.layoutIfNeeded()
        }
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
            widthConstraint = imageView.autoSetDimension(.width, toSize: size.width)
            heightConstraint = imageView.autoSetDimension(.height, toSize: size.height)
        }

        addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoCenterInSuperview()
    }
}
