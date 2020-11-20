final class ChatView: View {
    private let style: ChatStyle
    private let header: Header

    init(with style: ChatStyle) {
        self.style = style
        self.header = Header(with: style.headerStyle,
                             leftItem: .back)
        super.init()
        setup()
        layout()
    }

    private func setup() {
        backgroundColor = style.backgroundColor
    }

    private func layout() {
        addSubview(header)
        header.autoPinEdgesToSuperviewEdges(with: .zero,
                                            excludingEdge: .bottom)
    }
}
