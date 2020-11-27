import UIKit
import PureLayout

class Header: UIView {
    var leftItem: UIView? {
        get { return leftItemContainer.subviews.first }
        set {
            leftItemContainer.subviews.first?.removeFromSuperview()
            if let item = newValue {
                leftItemContainer.addSubview(item)
                item.autoPinEdgesToSuperviewEdges()
                item.tintColor = style.leftItemColor
            }
        }
    }
    var rightItem: UIView? {
        get { return rightItemContainer.subviews.first }
        set {
            rightItemContainer.subviews.first?.removeFromSuperview()
            if let item = newValue {
                rightItemContainer.addSubview(item)
                item.autoPinEdgesToSuperviewEdges()
                item.tintColor = style.rightItemColor
            }
        }
    }

    private let style: HeaderStyle
    private let extendsUnderStatusBar: Bool
    private let leftItemContainer = UIView()
    private let rightItemContainer = UIView()
    private let titleLabel = UILabel()
    private let contentView = UIView()
    private let kContentInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    private let kContentHeight: CGFloat = 30
    private let kHeight: CGFloat = 68

    public init(with style: HeaderStyle,
                extendsUnderStatusBar: Bool = true) {
        self.style = style
        self.extendsUnderStatusBar = extendsUnderStatusBar
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
    }

    private func layout() {
        let statusBarHeight: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20.0
        let height = extendsUnderStatusBar
            ? kHeight + statusBarHeight
            : kHeight
        autoSetDimension(.height, toSize: height)

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
}
