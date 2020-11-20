import UIKit
import PureLayout

class Header: UIView {
    enum Item {
        case back
        case close
    }

    private let style: HeaderStyle
    private let leftItem: Item
    private let extendsUnderStatusBar: Bool
    private let leftContainer = UIView()
    private let middleContainer = UIView()
    private let rightContainer = UIView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    private let kHeight: CGFloat = 68

    public init(with style: HeaderStyle,
                leftItem: Item,
                extendsUnderStatusBar: Bool = true) {
        self.style = style
        self.leftItem = leftItem
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
        titleLabel.textColor = style.titleFontColor
        titleLabel.textAlignment = .center
        titleLabel.text = style.title

        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        //stackView.alignment = .center
        stackView.addArrangedSubviews([
            leftContainer,
            middleContainer,
            rightContainer
        ])

        /*leftContainer.backgroundColor = .red
        middleContainer.backgroundColor = .black
        rightContainer.backgroundColor = .gray*/
    }

    private func layout() {
        let statusBarHeight: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20.0
        let height = extendsUnderStatusBar
            ? kHeight + statusBarHeight
            : kHeight
        autoSetDimension(.height, toSize: height)

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .init(top: 0, left: 10, bottom: 10, right: 10),
                                               excludingEdge: .top)
        stackView.autoPinEdge(toSuperviewEdge: .top,
                              withInset: 10,
                              relation: .greaterThanOrEqual)

        middleContainer.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges()

        let back = Button(style: .back)
        leftContainer.addSubview(back)
        back.autoPinEdgesToSuperviewEdges()

        let close = Button(style: .close)
        rightContainer.addSubview(close)
        close.autoPinEdgesToSuperviewEdges()
    }
}
