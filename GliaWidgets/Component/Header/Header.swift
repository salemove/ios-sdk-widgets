import UIKit
import PureLayout

class Header: UIView {
    var leftItem: UIView? {
        get { leftItemContainer.subviews.first }
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
        get { rightItemContainer.subviews.first }
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
    private let stackView = UIStackView()
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

        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.addArrangedSubviews([
            leftItemContainer,
            titleLabel,
            rightItemContainer
        ])
    }

    private func layout() {
        let statusBarHeight: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20.0
        let height = extendsUnderStatusBar
            ? kHeight + statusBarHeight
            : kHeight
        autoSetDimension(.height, toSize: height)

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10),
                                               excludingEdge: .top)
        stackView.autoPinEdge(toSuperviewEdge: .top,
                              withInset: 10,
                              relation: .greaterThanOrEqual)
    }
}
