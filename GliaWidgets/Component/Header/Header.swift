import UIKit
import PureLayout

class Header: UIView {
    enum Effect {
        case none
        case darkBlur
    }

    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var effect: Effect = .none {
        didSet {
            switch effect {
            case .none:
                effectView?.removeFromSuperview()
                effectView = nil
            case .darkBlur:
                let effect = UIBlurEffect(style: .dark)
                let effectView = UIVisualEffectView(effect: effect)
                self.effectView = effectView
                insertSubview(effectView, at: 0)
                effectView.autoPinEdgesToSuperviewEdges()
            }
        }
    }

    private let style: HeaderStyle
    private let leftItemContainer = UIView()
    private let rightItemContainer = UIView()
    private let titleLabel = UILabel()
    private let contentView = UIView()
    private var effectView: UIVisualEffectView?
    private var heightConstraint: NSLayoutConstraint?
    private let kContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 10, right: 16)
    private let kContentHeight: CGFloat = 30
    private let kHeight: CGFloat = 58

    public init(with style: HeaderStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeight()
    }

    public func setLeftItem(_ item: UIView?, animated: Bool) {
        setItem(item, to: leftItemContainer, animated: animated)
    }

    public func setRightItem(_ item: UIView?, animated: Bool) {
        setItem(item, to: rightItemContainer, animated: animated)
    }

    private func setItem(_ item: UIView?, to container: UIView, animated: Bool) {
        let currentItem = container.subviews.first

        UIView.animate(withDuration: animated ? 0.2 : 0.0) {
            currentItem?.alpha = 0.0
        } completion: { _ in
            currentItem?.removeFromSuperview()
            if let item = item {
                item.alpha = 0.0
                container.addSubview(item)
                item.autoPinEdge(toSuperviewEdge: .left, withInset: 0, relation: .greaterThanOrEqual)
                item.autoPinEdge(toSuperviewEdge: .top, withInset: 0, relation: .greaterThanOrEqual)
                item.autoPinEdge(toSuperviewEdge: .right, withInset: 0, relation: .greaterThanOrEqual)
                item.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)
                item.autoCenterInSuperview()
                UIView.animate(withDuration: animated ? 0.2 : 0.0) {
                    item.alpha = 1.0
                }
            }
        }
    }

    private func setup() {
        backgroundColor = style.backgroundColor

        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        titleLabel.textAlignment = .center
    }

    private func layout() {
        heightConstraint = autoSetDimension(.height, toSize: kHeight)

        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: kContentInsets, excludingEdge: .top)
        contentView.autoSetDimension(.height, toSize: kContentHeight)

        contentView.addSubview(titleLabel)
        titleLabel.autoPinEdge(toSuperviewEdge: .left)
        titleLabel.autoPinEdge(toSuperviewEdge: .right)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(leftItemContainer)
        leftItemContainer.autoPinEdge(toSuperviewEdge: .left)
        leftItemContainer.autoAlignAxis(toSuperviewAxis: .horizontal)

        contentView.addSubview(rightItemContainer)
        rightItemContainer.autoPinEdge(toSuperviewEdge: .right)
        rightItemContainer.autoAlignAxis(toSuperviewAxis: .horizontal)

        updateHeight()
    }

    private func updateHeight() {
        heightConstraint?.constant = kHeight + safeAreaInsets.top
    }
}
