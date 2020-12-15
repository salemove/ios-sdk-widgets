import UIKit
import PureLayout

class Header: UIView {
    private let style: HeaderStyle
    private let leftItemContainer = UIView()
    private let rightItemContainer = UIView()
    private let titleLabel = UILabel()
    private let contentView = UIView()
    private var heightLayoutConstraint: NSLayoutConstraint?
    private let kContentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
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

    private func setup() {
        backgroundColor = style.backgroundColor

        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        titleLabel.textAlignment = .center
        titleLabel.text = style.title

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func setLeftItem(_ item: UIView?, animated: Bool) {
        item?.tintColor = style.leftItemColor
        setItem(item, to: leftItemContainer, animated: animated)
    }

    public func setRightItem(_ item: UIView?, animated: Bool) {
        item?.tintColor = style.rightItemColor
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

    private func layout() {
        heightLayoutConstraint = autoSetDimension(.height, toSize: kHeight)
        updateHeight()

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
    }

    private func updateHeight() {
        let isPortrait = [.portrait, .portraitUpsideDown].contains(UIDevice.current.orientation)
        var height: CGFloat = kHeight

        if isPortrait {
            if let safeAreaTopInsets = UIApplication.shared.keyWindow?.safeAreaInsets.top {
                height += safeAreaTopInsets
            }
        }

        heightLayoutConstraint?.constant = height
    }

    @objc private func orientationChanged() {
        updateHeight()
    }
}
