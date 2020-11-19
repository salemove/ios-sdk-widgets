final class ChatView: View {
    private let style: ChatStyle

    init(with style: ChatStyle) {
        self.style = style
        super.init()
        setup()
        layout()
    }

    private func setup() {
        apply(style: style)
    }

    private func apply(style: ChatStyle) {}

    private func layout() {}
}
