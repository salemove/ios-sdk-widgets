import UIKit

extension CallVisualizer.VideoCallView {
    final class ConnectOperatorView: BaseView {

        // MARK: - Properties

        var props: Props {
            didSet {
                renderProps()
            }
        }

        let imageView: UserImageView
        private var animationView: ConnectAnimationView?
        private var widthConstraint: NSLayoutConstraint?
        private var heightConstraint: NSLayoutConstraint?
        private let animationViewSize: CGFloat = 142

        private var renderedAnimating: Bool = false {
            didSet {
                guard renderedAnimating != oldValue else { return }
                if renderedAnimating {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }

        // MARK: - Initializer
        init(props: Props) {
            self.props = props
            self.imageView = .init(props: props.userImageViewProps)
            super.init()
        }

        required init() {
            fatalError("init() has not been implemented")
        }

        // MARK: - Overrides

        override func setup() {
            super.setup()
            isAccessibilityElement = true
            accessibilityTraits = .image
            accessibilityLabel = props.style.accessibility.label
            accessibilityHint = props.style.accessibility.hint
        }

        override func defineLayout() {
            super.defineLayout()
            addSubview(imageView)
            NSLayoutConstraint.autoSetPriority(.defaultHigh) {
                imageView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
                imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
                imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
                imageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
            }
            widthConstraint = imageView.autoSetDimension(.width, toSize: props.size.size.width)
            heightConstraint = imageView.autoSetDimension(.height, toSize: props.size.size.height)
            imageView.autoCenterInSuperview()
        }
    }
}

// MARK: - Props

extension CallVisualizer.VideoCallView.ConnectOperatorView {
    struct Props: Equatable {
        let style: ConnectOperatorStyle
        let size: SizeObject
        let operatorAnimate: Bool
        let userImageViewProps: CallVisualizer.VideoCallView.UserImageView.Props
    }
}

extension CallVisualizer.VideoCallView.ConnectOperatorView.Props {
    enum Size {
        case normal
        case large

        var width: CGFloat {
            switch self {
            case .normal: return 80
            case .large: return 120
            }
        }

        var height: CGFloat {
            switch self {
            case .normal: return 80
            case .large: return 120
            }
        }
    }

    struct SizeObject: Equatable {
        let size: Size
        let animated: Bool
    }
}

// MARK: - Private

private extension CallVisualizer.VideoCallView.ConnectOperatorView {
    func renderProps() {
        setSize(size: props.size)
        renderedAnimating = props.operatorAnimate
        imageView.props = props.userImageViewProps
    }

    func setSize(size: Props.SizeObject) {
        UIView.animate(withDuration: size.animated ? 0.3 : 0.0) {
            self.widthConstraint?.constant = size.size.width
            self.heightConstraint?.constant = size.size.height
            self.layoutIfNeeded()
        }
    }

    func startAnimating() {
        guard animationView == nil else { return }

        let animationView = ConnectAnimationView(
            color: props.style.animationColor,
            size: animationViewSize
        )
        self.animationView = animationView

        insertSubview(animationView, at: 0)
        animationView.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .top, withInset: 0)
        animationView.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
        animationView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        animationView.autoCenterInSuperview()
        animationView.autoSetDimensions(to: .init(width: animationViewSize, height: animationViewSize))
        animationView.startAnimating()
    }

    func stopAnimating() {
        animationView?.removeFromSuperview()
        animationView = nil
    }
}
