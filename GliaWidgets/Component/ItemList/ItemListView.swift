import UIKit

class ItemListView: UIView {
    var items: [ListItemStyle] = [] {
        didSet { updateItems(items) }
    }
    var itemTapped: ((Int) -> Void)?

    private let stackView = UIStackView()
    private let style: ItemListStyle

    public init(with style: ItemListStyle) {
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
        stackView.axis = .vertical
        stackView.spacing = 0
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    private func updateItems(_ styles: [ListItemStyle]) {
        stackView.removeArrangedSubviews()
        styles.enumerated().forEach({
            let itemStyle = $0.element
            let itemIndex = $0.offset
            let itemView = ListItemView(with: itemStyle)
            itemView.tap = { [weak self] in self?.itemTapped?(itemIndex) }
            stackView.addArrangedSubview(itemView)
            if $0.offset < styles.count - 1 {
                let separator = makeSeparator(color: style.separatorColor)
                stackView.addArrangedSubview(separator)
            }
        })
    }

    private func makeSeparator(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.autoSetDimension(.height, toSize: 0.5)
        return view
    }
}
