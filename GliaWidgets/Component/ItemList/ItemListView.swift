import UIKit

class ItemListView: UIView {
    var items: [ListItemStyle] = [] {
        didSet { updateItems(items) }
    }
    var itemTapped: ((ListItemKind) -> Void)?

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
        backgroundColor = style.backgroundColor

        stackView.axis = .vertical

        items = style.items
    }

    private func layout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    private func updateItems(_ styles: [ListItemStyle]) {
        stackView.removeArrangedSubviews()
        styles.forEach {
            let itemView = ListItemView(with: $0)
            itemView.tap = { [weak self] in self?.itemTapped?($0) }
            stackView.addArrangedSubview(itemView)
            if $0 !== styles.last {
                let separator = makeSeparator(color: style.separatorColor)
                stackView.addArrangedSubview(separator)
            }
        }
    }

    private func makeSeparator(color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.autoSetDimension(.height, toSize: 0.5)
        return view
    }
}
